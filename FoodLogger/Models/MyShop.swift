//
//  MyShop.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/09/23.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class MyShop: HotpepperShop {
    /// 位置
    var coordinate: CLLocationCoordinate2D?
    /// 評価
    var rating: Int = 1
    /// 作成日
    var created: Double = Date().timeIntervalSince1970
    
    /**
     初期化処理
     
     - parameter id: ショップID
     - parameter name: ショップ名
     - parameter category: ショップカテゴリ
     - parameter imageURL: ショップ画像URL
     - parameter coordinate: 位置
     - parameter shopURL: ショップURL
     - parameter rating: 評価
     */
    init(id: String, name: String, category: String, imageURL: String, coordinate: CLLocationCoordinate2D, shopURL: String, rating: Int) {
        super.init(id: id, name: name, category: category, imageURL: imageURL, latitude: coordinate.latitude, longitude: coordinate.longitude, shopURL: shopURL)
        self.rating = rating
    }
    
    /**
     初期化処理
     
     - parameter data: ショップデータ
     */
    override init(data: JSON) {
        super.init(data: data)
        self.coordinate = CLLocationCoordinate2D.init(latitude: atof(data["lat"].string ?? "0"), longitude: atof(data["lng"].string ?? "0"))
    }
}
