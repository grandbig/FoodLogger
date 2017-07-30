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

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    /// UITableView
    @IBOutlet weak var tableView: UITableView!
    /// Realm管理マネージャ
    internal var realmShopManager: RealmShopManager = RealmShopManager()
    /// 検索ショップ
    internal var shops: Results<RealmShop>!
    /// UITableViewCellの高さ
    private let rowHeight: CGFloat = 88.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib.init(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ShopInfoCell")
        self.tableView.rowHeight = self.rowHeight
        
        if let savedShops = self.realmShopManager.selectAll() {
            self.shops = savedShops
        }
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
        let shop = HotpepperShop(id: selectedShop.id, name: selectedShop.name, category: selectedShop.category, imageURL: selectedShop.imageURL, latitude: selectedShop.latitude, longitude: selectedShop.longitude, shopURL: selectedShop.shopURL)
        // 画面遷移
        performSegue(withIdentifier: "shopDetailSegueFromList", sender: shop)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count 
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopInfoCell", for: indexPath) as? CustomTableViewCell
        cell?.nameLabel.text = self.shops[indexPath.row].name
        cell?.categoryLabel.text = self.shops[indexPath.row].category 
        if let imageURL = URL(string: self.shops[indexPath.row].imageURL) {
            cell?.imgView?.af_setImage(withURL: imageURL, placeholderImage: UIImage(named: "NoImageIcon"))
        }
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell!
    }
    
    // MARK: Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem.init()
        backButton.title = "戻る"
        backButton.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = backButton
        
        if segue.identifier == "shopDetailSegueFromList" {
            guard let shopDetailViewController = segue.destination as? ShopDetailViewController else {
                return
            }
            guard let shop = sender as? HotpepperShop else {
                return
            }
            shopDetailViewController.shop = shop
        }
    }
}
