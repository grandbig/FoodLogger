//
//  HotpepperShop.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/22.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 ホットペッパーグルメAPIで取得した店舗オブジェクト
 */
class HotpepperShop {
    
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
     - parameter imageURL: 店舗画像URL
     - parameter latitude: 緯度
     - paramter longitude: 経度
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
        self.category = data["genre"]["name"].string ?? "カテゴリ不明"
        self.imageURL = data["photo"]["mobile"]["l"].string
        self.latitude = atof(data["lat"].string ?? "0")
        self.longitude = atof(data["lng"].string ?? "0")
    }
}
