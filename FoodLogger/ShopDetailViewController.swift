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
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    private var realmShopManager: RealmShopManager = RealmShopManager()
    public var shop: HotpepperShop!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.delegate = self
        
        if let shopURL = self.shop.shopURL, let url = URL(string: shopURL) {
            let urlRequest = URLRequest(url: url)
            self.webView.loadRequest(urlRequest)
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.indicatorView.isHidden = true
    }
    
    // MARK: Button Action
    @IBAction func touchSaveButton(_ sender: Any) {
        self.realmShopManager.createShop(shop: self.shop)
        self.saveButton.isEnabled = false
    }
}
