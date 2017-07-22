//
//  GurunaviShop.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/22.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 ぐるなびAPIで取得した店舗オブジェクト
 */
class GurunaviShop {
    
    /// 店舗ID
    var id: String?
    /// 店舗名
    var name: String?
    /// 店舗カテゴリ
    var category: String?
    /// 店舗画像URL
    var imageURL: String?
    /// 緯度
    var latitude: Double?
    /// 経度
    var longitude: Double?
    
    /**
     初期化処理
     
     - parameter id: 店舗ID
     - parameter name: 店舗名
     - parameter category: 店舗カテゴリ
     - paramter imageURL: 店舗画像URL
     - parameter latitude: 緯度
     - parameter longitude: 経度
     */
    init(id: String, name: String, category: String, imageURL: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.category = category
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /**
     初期化処理
     
     - parameter data: 店舗データ
     */
    init(data: JSON) {
        self.id = data["id"].string ?? "ID不明"
        self.name = data["name"].string ?? "店舗名不明"
        self.category = data["category"].string ?? "カテゴリ不明"
        self.imageURL = self.getShopImage(imageURL: data["image_url"])
        self.latitude = atof(data["latitude"].string ?? "0")
        self.longitude = atof(data["longitude"].string ?? "0")
    }
    
    /**
     ぐるなびレストラン検索APIで取得した店舗画像JSONから有効な店舗画像URLを取得する処理
     
     - parameter imageURL: ぐるなびレストラン検索APIで取得した店舗画像JSON
     - returns: 有効な店舗画像URL
     */
    func getShopImage(imageURL: JSON) -> String? {
        if let image1 = imageURL["shop_image1"].string {
            return image1
        } else if let image2 = imageURL["shop_image2"].string {
            return image2
        } else if let qrcode = imageURL["qrcode"].string {
            return qrcode
        } else {
            return nil
        }
    }
}
