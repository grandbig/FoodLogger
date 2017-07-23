//
//  RealmShop.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/22.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import RealmSwift

/**
 Realmに保存する店舗オブジェクト
 */
class RealmShop: Object {
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var category: String = ""
    dynamic var imageURL: String = ""
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var shopURL: String = ""
    dynamic var created: Double = Date().timeIntervalSince1970
    
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
