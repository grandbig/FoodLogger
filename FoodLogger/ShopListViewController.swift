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
import SwiftyJSON
import AlamofireImage

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    /// UITableView
    @IBOutlet weak var tableView: UITableView!
    /// 検索ショップ
    internal var shops: [JSON]!
    /// 現在地
    internal var myLocation: CLLocation!
    /// UITableViewCellの高さ
    private let rowHeight: CGFloat = 88.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib.init(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ShopInfoCell")
        self.tableView.rowHeight = self.rowHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 画面遷移
        let shop = HotpepperShop(data: self.shops[indexPath.row])
        performSegue(withIdentifier: "shopDetailSegueFromList", sender: shop)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count 
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopInfoCell", for: indexPath) as? CustomTableViewCell
        cell?.nameLabel.text = self.shops[indexPath.row]["name"].string ?? "-"
        cell?.categoryLabel.text = self.shops[indexPath.row]["genre"]["name"].string ?? "-"
        if let imageURL = URL(string: self.shops[indexPath.row]["photo"]["mobile"]["l"].string!) {
            cell?.imgView?.af_setImage(withURL: imageURL, placeholderImage: UIImage(named: "NoImageIcon"))
        }
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell!
    }
    
    // MARK: Button Action
    @IBAction func changeMapView(_ sender: Any) {
        // 画面遷移
        self.dismiss(animated: true, completion: {
        })
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
            shopDetailViewController.myLocation = self.myLocation
        }
    }
}
