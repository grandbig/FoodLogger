//
//  ShopDetailViewController.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/23.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ShopDetailViewController: UIViewController, UIWebViewDelegate {
    
    /// WebView
    @IBOutlet weak var webView: UIWebView!
    /// IndicatorView
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    /// ショップ保存ボタン
    @IBOutlet weak var saveButton: UIBarButtonItem!
    /// 現在地からショップまでの許容できる最大距離
    private var maxDistance: Double = 300
    /// Realm管理マネージャ
    private var realmShopManager: RealmShopManager = RealmShopManager()
    /// 現在地
    internal var myLocation: CLLocation?
    /// ショップ
    internal var shop: HotpepperShop!
    /// ショップの保存済/未保存フラグ
    internal var isSaved: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.delegate = self
        
        if let shopURL = self.shop.shopURL, let url = URL(string: shopURL) {
            let urlRequest = URLRequest(url: url)
            self.webView.loadRequest(urlRequest)
        }
        if let accuracy = self.myLocation?.horizontalAccuracy, accuracy > 0 {
            self.maxDistance = accuracy
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let id = shop.id {
            if self.realmShopManager.exsitsById(id) {
                // 既に保存済みの場合はボタンをDisabledに変更
                self.saveButton.isEnabled = false
            }
        }
        self.isSaved = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIWebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.indicatorView.isHidden = true
    }
    
    // MARK: Button Action
    @IBAction func touchSaveButton(_ sender: Any) {
        // 確認アラートを表示
        self.showConfirm(title: "確認", message: "このショップへの来店履歴を保存しますか？", okCompletion: {
            guard let shopLatitude = self.shop.latitude, let shopLongitude = self.shop.longitude else {
                self.showAlert(title: "確認", message: "ショップの情報が正しく取得できません。", completion: {})
                return
            }
            guard let coordinate = self.myLocation?.coordinate else {
                self.showAlert(title: "確認", message: "現在地が正しく取得できません。", completion: {})
                return
            }
            let shopLocation = CLLocationCoordinate2D(latitude: shopLatitude, longitude: shopLongitude)
            if self.getDistance(from: coordinate, to: shopLocation) > self.maxDistance {
                // ショップから離れすぎている場合
                self.showAlert(title: "確認", message: "ショップに近づいて再度お試しください", completion: {})
                return
            }
            // データを保存
            self.realmShopManager.createShop(shop: self.shop)
            self.saveButton.isEnabled = false
            self.isSaved = true
            
            let message = "続けて来店ショップに対する詳細メモを追加しますか？\n(後から、設定 > ショップ履歴より情報を追加できます。)"
            self.showConfirm(title: "確認", message: message, okCompletion: { 
                self.performSegue(withIdentifier: "createShopMemoSegue", sender: nil)
            }, cancelCompletion: {
            })
            
            // TODO: 設定 > ショップ履歴から遷移する画面は詳細メモ画面に変更する (WebViewへの遷移はできるようにする)
            // TODO: 別ビューは「料理写真の保存, 人数, 用途, 自己評価, 備考」を編集可能にする
            // TODO: 保存日時は自動で表示
        }) {
        }
    }
    
    // MARK: Other
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
}
