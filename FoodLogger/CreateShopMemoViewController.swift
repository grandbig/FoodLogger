//
//  CreateShopMemoViewController.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/08/02.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SafariServices
import HCSStarRatingView
import NVActivityIndicatorView
import RealmSwift

class CreateShopMemoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate {
    
    /// 評価用のレーティングビュー
    @IBOutlet weak var ratingBar: HCSStarRatingView!
    /// UICollectionView
    @IBOutlet weak var collectionView: UICollectionView!
    /// テキストエリア
    @IBOutlet weak var placeTextArea: UIPlaceHolderTextView!
    /// ローディングビュー
    @IBOutlet weak var loadingView: UIView!
    /// ローディングアイコン
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    /// ナビゲーションバーに右ボタン
    @IBOutlet weak var navRightButton: UIButton!
    /// 現在地
    internal var myLocation: CLLocation?
    /// ショップ
    internal var shop: HotpepperShop!
    /// ショップの保存済/未保存フラグ
    internal var isSaved: Bool = false
    /// 店舗情報ボタンの表示/非表示フラグ
    internal var isRightButton: Bool = false
    /// Realm管理マネージャ
    private var realmShopManager = RealmShopManager.sharedInstance
    /// 現在地からショップまでの許容できる最大距離
    private var maxDistance: Double = 300
    /// 食品画像リスト
    private var images: [UIImage]! = [UIImage]()
    /// 選択したIndexPath
    private var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "メモ"
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.placeTextArea.placeHolder = "メモを入力"
        self.placeTextArea.placeHolderColor = UIColor(red: 0.75, green: 0.75, blue: 0.77, alpha: 1.0)
        self.createToolBar()
        
        if let accuracy = self.myLocation?.horizontalAccuracy, accuracy > 10 {
            self.maxDistance = accuracy
        }
        
        guard let shopId = self.shop.id else {
            return
        }
        
        if let shop = self.realmShopManager.selectById(shopId)?[0] {
            // 保存済みショップの場合
            self.ratingBar.value = CGFloat(shop.rating)
            self.placeTextArea.text = shop.memo
            let foods = shop.foods
            for food in foods {
                let image = UIImage(data: food.imageData)
                self.images.append(image!)
            }
            self.isSaved = true
        }
        
        if !self.isRightButton {
            self.navRightButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if self.images.count > 0 {
            // 保存した写真がある場合
            if (self.images.count - 1) >= indexPath.row {
                // 保存した写真の場合
                cell.backgroundView = UIImageView(image: self.images[indexPath.row])
            } else {
                // 写真追加枠
                cell.backgroundView = UIImageView(image: UIImage(named: "NoImageIcon"))
            }
        } else {
            // 保存した写真がない場合
            cell.backgroundView = UIImageView(image: UIImage(named: "NoImageIcon"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.images.count > 0 {
            return self.images.count + 1
        }
        return 1
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.pickImageFromCamera()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let info = info[UIImagePickerControllerOriginalImage] else {
            return
        }
        guard let image = info as? UIImage else {
            return
        }
        if let selectedCell = self.collectionView.cellForItem(at: self.selectedIndexPath) {
            selectedCell.backgroundView = UIImageView(image: image)
            
            if self.images.count < self.selectedIndexPath.row + 1 {
                self.images.append(image)
                // UICollectionViewのリロード
                self.collectionView.reloadData()
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Button Action
    @IBAction func saveShop(_ sender: Any) {
        if !self.isSaved {
            // 新規保存の場合
            self.saveShop()
        } else {
            // 既存の更新の場合
            self.updateShop()
        }
    }
    
    @IBAction func showShopInfo(_ sender: Any) {
        let shopURL = NSURL(string: self.shop.shopURL!)
        
        if let shopURL = shopURL {
            let safariViewController = SFSafariViewController(url: shopURL as URL)
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: Other
    /// キーボード用ツールバーの生成処理
    func createToolBar() {
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        kbToolBar.barStyle = UIBarStyle.default
        kbToolBar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneButtonTapped))
        kbToolBar.items = [spacer, commitButton]
        
        self.placeTextArea.inputAccessoryView = kbToolBar
    }
    
    /// ツールバーのDONEボタンタップ時の処理
    func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
    /// カメラビューの表示処理
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.camera
            present(controller, animated: true, completion: nil)
        }
    }
    
    /**
     ローディングビューの表示
     */
    private func showLoadingView() {
        self.loadingView.isHidden = false
        self.indicatorView.startAnimating()
    }
    
    /**
     ローディングビューの非表示
     */
    private func hiddenLoadingView() {
        self.loadingView.isHidden = true
        self.indicatorView.stopAnimating()
    }
    
    /**
     2点間の距離を取得
     
     - parameter from: 1つ目の位置情報
     - parameter to: 2つ目のいち1つ目の位置情報
     - returns: 2点間の距離 (単位は [m] )
     */
    private func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: to.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return toLocation.distance(from: fromLocation)
    }
    
    /**
     ショップの新規保存処理
     */
    private func saveShop() {
        let globalQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let mainQueue = DispatchQueue.main
        
        // 確認アラートを表示
        self.showConfirm(title: "確認", message: "このショップへの来店履歴を保存しますか？", okCompletion: {
            // ローディングビューの表示
            self.showLoadingView()
            
            globalQueue.async {
                guard let shopLatitude = self.shop.latitude, let shopLongitude = self.shop.longitude else {
                    // ショップの位置が不明な場合
                    mainQueue.async {
                        // ローディングビューの非表示
                        self.hiddenLoadingView()
                        self.showAlert(title: "確認", message: "ショップの情報が正しく取得できません。", completion: {})
                    }
                    return
                }
                guard let coordinate = self.myLocation?.coordinate else {
                    // 現在地が不明な場合
                    mainQueue.async {
                        // ローディングビューの非表示
                        self.hiddenLoadingView()
                        self.showAlert(title: "確認", message: "現在地が正しく取得できません。", completion: {})
                    }
                    return
                }
                let shopLocation = CLLocationCoordinate2D(latitude: shopLatitude, longitude: shopLongitude)
                if self.getDistance(from: coordinate, to: shopLocation) > self.maxDistance {
                    // ショップが現在地から遠い場合
                    mainQueue.async {
                        // ローディングビューの非表示
                        self.hiddenLoadingView()
                        self.showAlert(title: "確認", message: "ショップに近づいて再度お試しください", completion: {})
                    }
                    return
                }
                // 画像データの変換
                var imageDatas: [Data]? = nil
                if let images = self.images, images.count > 0 {
                    imageDatas = [Data]()
                    for image in images {
                        let imageData = NSData.init(data: UIImageJPEGRepresentation(image, 1.0)!) as Data
                        imageDatas?.append(imageData)
                    }
                }
                // データを保存
                self.realmShopManager.createShop(shop: self.shop, rating: Int(self.ratingBar.value), images: imageDatas, memo: self.placeTextArea.text)
                
                mainQueue.async {
                    // ローディングビューの非表示
                    self.hiddenLoadingView()
                    
                    // 保存完了アラートを表示
                    self.showAlert(title: "確認", message: "ショップへの来店履歴を保存しました", completion: {
                        self.isSaved = true
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                }
            }
        }) {
        }
    }
    
    /**
     ショップの更新処理
     */
    private func updateShop() {
        let globalQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let mainQueue = DispatchQueue.main
        
        // 確認アラートを表示
        self.showConfirm(title: "確認", message: "このショップへの記録を更新しますか？", okCompletion: {
            // ローディングビューの表示
            self.showLoadingView()
            
            globalQueue.async {
                // 画像データの変換
                var imageDatas: [Data]? = nil
                if let images = self.images, images.count > 0 {
                    imageDatas = [Data]()
                    for image in images {
                        let imageData = NSData.init(data: UIImageJPEGRepresentation(image, 1.0)!) as Data
                        imageDatas?.append(imageData)
                    }
                }
                // データを更新
                guard let shopId = self.shop.id else {
                    mainQueue.async {
                        // ローディングビューの非表示
                        self.hiddenLoadingView()
                        self.showAlert(title: "確認", message: "ショップ情報が正しく取得できません。", completion: {})
                    }
                    return
                }
                self.realmShopManager.updateShop(id: shopId, rating: Int(self.ratingBar.value), memo: self.placeTextArea.text, images: imageDatas)
                
                mainQueue.async {
                    // ローディングビューの非表示
                    self.hiddenLoadingView()
                    // 保存完了アラートを表示
                    self.showAlert(title: "確認", message: "ショップの記録を更新しました", completion: {
                        self.isSaved = true
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }) {
        }
    }
}
