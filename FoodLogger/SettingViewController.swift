//
//  SettingViewController.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/30.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var rowTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "設定"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.rowTitles = ["オープンソースライセンス", "アプリバージョン"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "licenseSegue", sender: nil)
        default:
            break
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowTitles.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = self.rowTitles[indexPath.row]
        
        switch indexPath.row {
        case 0:
            cell.detailTextLabel?.text = ""
        case 1:
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.detailTextLabel?.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
            cell.detailTextLabel?.textColor = UIColor.gray
        default:
            break
        }
        
        return cell
    }
    
    // MARK: Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem.init()
        backButton.title = "戻る"
        backButton.tintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = backButton
    }
}
