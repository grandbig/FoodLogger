//
//  ShopDetailViewController.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/23.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class ShopDetailViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    private var realmShopManager: RealmShopManager = RealmShopManager()
    public var shop: HotpepperShop!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let shopURL = self.shop.shopURL, let url = URL(string: shopURL) {
            let urlRequest = URLRequest(url: url)
            self.webView.loadRequest(urlRequest)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button Action
    @IBAction func touchSaveButton(_ sender: Any) {
        // TODO: 保存済みであればdisabledにボタンを変更する
        // TODO: 未保存であればshopオブジェクトから情報を取得して保存する
    }
}
