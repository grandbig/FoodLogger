//
//  ShopListViewController.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/28.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RealmSwift
import SwiftyJSON
import AlamofireImage

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    /// UITableView
    @IBOutlet weak var tableView: UITableView!
    /// Realm管理マネージャ
    internal var realmShopManager = RealmShopManager.sharedInstance
    /// 検索ショップ
    internal var shops: Results<RealmShop>!
    /// UITableViewCellの高さ
    private let rowHeight: CGFloat = 88.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "レストランの来店履歴"
        self.navigationController?.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib.init(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ShopInfoCell")
        self.tableView.rowHeight = rowHeight
        
        if let savedShops = self.realmShopManager.selectAll() {
            self.shops = savedShops
        }
        self.tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedShop = self.shops[indexPath.row]
        let shop = Restaurant(id: selectedShop.id,
                              name: selectedShop.name,
                              latitude: String(selectedShop.latitude),
                              longitude: String(selectedShop.longitude),
                              category: selectedShop.category,
                              url: selectedShop.shopURL,
                              shopImage1: selectedShop.imageURL,
                              shopImage2: nil)
        // 画面遷移
        performSegue(withIdentifier: "editShopMemoSegue", sender: shop)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count 
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopInfoCell", for: indexPath) as? CustomTableViewCell
        cell?.nameLabel.text = self.shops[indexPath.row].name
        cell?.ratingLabel.text = Rating().changeRatingValue(rating: self.shops[indexPath.row].rating)
        cell?.datetimeLabel.text = self.formatTimestamp(timestamp: self.shops[indexPath.row].created)
        if let imageURL = URL(string: self.shops[indexPath.row].imageURL) {
            cell?.imgView?.af_setImage(withURL: imageURL, placeholderImage: UIImage(named: "NoImageIcon"))
        }
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell!
    }
    
    // MARK: UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let createShopMemoViewController = fromVC as? CreateShopMemoViewController, toVC as? ShopListViewController != nil {
            // createShopMemoViewControllerから戻ってきた場合
            if createShopMemoViewController.isSaved {
                // ショップを新たに保存した場合
                self.tableView.reloadData()
            }
        }
        return nil
    }
    
    // MARK: Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem.init()
        backButton.title = "戻る"
        backButton.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = backButton
        
        if segue.identifier == "editShopMemoSegue" {
            guard let createShopMemoViewController = segue.destination as? CreateShopMemoViewController else {
                return
            }
            guard let shop = sender as? Restaurant else {
                return
            }
            createShopMemoViewController.shop = shop
            createShopMemoViewController.isRightButton = true
        }
    }
    
    // MARK: Other
    /**
     タイムスタンプを指定フォーマットの文字列に日時を変換する処理
     
     - parameter timestamp: タイムスタンプ
     - returns: 指定フォーマットの文字列の日時
     */
    private func formatTimestamp(timestamp: Double) -> String {
        let date = Date.init(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm"
        return formatter.string(from: date)
    }
}
