//
//  CreateShopMemoViewController.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/08/02.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import AARatingBar
import RealmSwift

class CreateShopMemoViewController: UIViewController, UICollectionViewDataSource {
    
    /// 評価用のレーティングビュー
    @IBOutlet weak var ratingBar: AARatingBar!
    /// UICollectionView
    @IBOutlet weak var collectionView: UICollectionView!
    /// テキストエリア
    @IBOutlet weak var placeTextArea: UIPlaceHolderTextView!
    /// Realm管理マネージャ
    private var realmShopManager = RealmShopManager.sharedInstance
    /// ショップ
    internal var shop: Results<RealmShop>?
    /// ショップID
    internal var shopId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        
        self.placeTextArea.placeHolder = "メモを入力"
        self.placeTextArea.placeHolderColor = UIColor(red: 0.75, green: 0.75, blue: 0.77, alpha: 1.0)
        self.createToolBar()
        
        self.shop = self.realmShopManager.selectById(self.shopId)
        if let shop = self.shop {
            self.ratingBar.value = CGFloat(shop[0].rating)
            self.placeTextArea.text = shop[0].memo
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as? CustomCollectionViewCell
        
        // 分かりやすいように背景色を青に
        //cell.backgroundColor = UIColor.blue
        
        if let foods = self.shop?[0].foods, foods.count > 0 {
            cell?.imageView.image = UIImage(data: foods[indexPath.row].imageData)
        } else {
            cell?.imageView.image = UIImage(named: "NoImageIcon")
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let foods = self.shop?[0].foods, foods.count > 0 {
            return foods.count
        }
        return 1
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
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
}
