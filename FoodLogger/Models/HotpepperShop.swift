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
 ホットペッパーグルメAPIで取得したショップオブジェクト
 */
class HotpepperShop {
    
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
    /// ショップURL
    var shopURL: String?

    /**
     初期化処理
     
     - parameter id: ショップID
     - parameter name: ショップ名
     - parameter category: ショップカテゴリ
     - parameter imageURL: ショップ画像URL
     - parameter latitude: 緯度
     - parameter longitude: 経度
     - parameter shopURL: ショップURL
     */
    init(id: String, name: String, category: String, imageURL: String, latitude: Double, longitude: Double, shopURL: String) {
        self.id = id
        self.name = name
        self.category = category
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.shopURL = shopURL
    }
    
    /**
     初期化処理
     
    - parameter data: ショップデータ
     */
    init(data: JSON) {
        self.id = data["id"].string ?? "ID不明"
        self.name = data["name"].string ?? "ショップ名不明"
        self.category = data["genre"]["name"].string ?? "カテゴリ不明"
        self.imageURL = data["photo"]["mobile"]["l"].string
        self.latitude = atof(data["lat"].string ?? "0")
        self.longitude = atof(data["lng"].string ?? "0")
        self.shopURL = data["urls"]["pc"].string
    }
}
