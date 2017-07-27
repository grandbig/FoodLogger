//
//  MarkerInfoContentsView.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/18.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class MarkerInfoContentsView: UIView {
    
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var shopImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibViewSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.xibViewSet()
    }
    
    internal func xibViewSet() {
        if let view = Bundle.main.loadNibNamed("MarkerInfoContentsView", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    
    /**
     データの設定処理
     
     - parameter shopName: ショップ名
     - parameter categoryName: カテゴリ名
     - parameter shopImageURLString: 画像URL
     */
    func setData(shopName: String?, categoryName: String?, shopImageURLString: String?) {
        // ショップ名の設定
        if let shopNameTextCount = shopName?.characters.count, shopNameTextCount > 0 {
            self.shopName.text = shopName
        } else {
            self.shopName.text = "ショップ名不明"
            self.shopName.textColor = UIColor.gray
        }
        // 詳細説明の設定
        if let categoryNameTextCount = categoryName?.characters.count, categoryNameTextCount > 0 {
            self.categoryName.text = categoryName
        } else {
            self.categoryName.text = "カテゴリ不明"
            self.categoryName.textColor = UIColor.gray
        }
        // 画像の設定
        if let shopImageURLStringTextCount = shopImageURLString?.characters.count, shopImageURLStringTextCount > 0 {
            if let shopImageURL = URL(string: shopImageURLString!) {
                self.shopImage.af_setImage(withURL: shopImageURL, placeholderImage: UIImage(named: "NoImageIcon"))
            } else {
                self.shopImage.image = UIImage(named: "NoImageIcon")
            }
        } else {
            self.shopImage.image = UIImage(named: "NoImageIcon")
        }
        
    }
}
