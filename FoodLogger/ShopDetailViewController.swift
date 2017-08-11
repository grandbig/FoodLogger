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
import NVActivityIndicatorView

class ShopDetailViewController: UIViewController, UIWebViewDelegate {
    
    /// WebView
    @IBOutlet weak var webView: UIWebView!
    /// ショップ保存ボタン
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    /// Realm管理マネージャ
    private var realmShopManager = RealmShopManager.sharedInstance
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
        self.indicatorView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isSaved = false
        if let id = shop.id {
            if self.realmShopManager.exsitsById(id) {
                // TODO: 既に保存済みの場合は編集ボタンに変える
                // 既に保存済みの場合はボタンをDisabledに変更
                self.saveButton.isEnabled = false
                self.isSaved = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIWebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.indicatorView.stopAnimating()
        
        UIView.animate(withDuration: 2.0) { 
            self.loadingView.isHidden = true
        }
    }
    
    // MARK: Button Action
    @IBAction func touchSaveButton(_ sender: Any) {
        self.performSegue(withIdentifier: "createShopMemoSegue", sender: nil)
    }
    
    // MARK: Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem.init()
        backButton.title = "戻る"
        backButton.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = backButton
        
        if segue.identifier == "createShopMemoSegue" {
            guard let createShopMemoViewController = segue.destination as? CreateShopMemoViewController else {
                return
            }
            createShopMemoViewController.shop = self.shop
            createShopMemoViewController.myLocation = self.myLocation
        }
    }
}
