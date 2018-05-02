//
//  RealmFood.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/08/05.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import RealmSwift

/**
 Realmに保存する食品オブジェクト
 */
class RealmFood: Object {
    /// ID
    @objc dynamic var id: String = NSUUID().uuidString
    /// 画像データ
    @objc dynamic var imageData: Data = Data()
    /// 保存日時(タイムスタンプ)
    @objc dynamic var created: Double = Date().timeIntervalSince1970
    
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
