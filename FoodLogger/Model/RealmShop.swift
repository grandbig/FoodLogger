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
 Realmに保存するショップオブジェクト
 */
class RealmShop: Object {
    /// ID
    @objc dynamic var id: String = ""
    /// 名前
    @objc dynamic var name: String = ""
    /// カテゴリ
    @objc dynamic var category: String = ""
    /// 画像URL
    @objc dynamic var imageURL: String = ""
    /// 緯度
    @objc dynamic var latitude: Double = 0.0
    /// 経度
    @objc dynamic var longitude: Double = 0.0
    /// ショップURL
    @objc dynamic var shopURL: String = ""
    /// 評価
    @objc dynamic var rating: Int = 0
    /// メモ
    @objc dynamic var memo: String = ""
    /// 食品データリスト
    let foods = List<RealmFood>()
    /// 食事種別
    @objc dynamic var mealTime: Int = 0
    /// 保存日時(タイムスタンプ)
    @objc dynamic var created: Double = Date().timeIntervalSince1970
    /// 更新日時(タイムスタンプ)
    @objc dynamic var updated: Double = Date().timeIntervalSince1970
    
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
