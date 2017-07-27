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
 ぐるなびAPIで取得したショップオブジェクト
 */
class GurunaviShop {
    
    /// ショップID
    var id: String?
    /// ショップ名
    var name: String?
    /// ショップカテゴリ
    var category: String?
    /// ショップ画像URL
    var imageURL: String?
    /// 緯度
    var latitude: Double?
    /// 経度
    var longitude: Double?
    
    /**
     初期化処理
     
     - parameter id: ショップID
     - parameter name: ショップ名
     - parameter category: ショップカテゴリ
     - paramter imageURL: ショップ画像URL
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
     
     - parameter data: ショップデータ
     */
    init(data: JSON) {
        self.id = data["id"].string ?? "ID不明"
        self.name = data["name"].string ?? "ショップ名不明"
        self.category = data["category"].string ?? "カテゴリ不明"
        self.imageURL = self.getShopImage(imageURL: data["image_url"])
        self.latitude = atof(data["latitude"].string ?? "0")
        self.longitude = atof(data["longitude"].string ?? "0")
    }
    
    /**
     ぐるなびレストラン検索APIで取得したショップ画像JSONから有効なショップ画像URLを取得する処理
     
     - parameter imageURL: ぐるなびレストラン検索APIで取得したショップ画像JSON
     - returns: 有効なショップ画像URL
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
