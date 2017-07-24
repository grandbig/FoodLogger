//
//  RealmShopManager.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/22.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import RealmSwift

class RealmShopManager {
    
    /// シングルトン
    static let sharedInstance = RealmShopManager()
    
    /// イニシャライザ
    init() {
    }
    
    /**
     店舗情報をRealmに保存する処理
     
     - parameter shop: 店舗データ
     */
    func createShop(shop: HotpepperShop) {
        do {
            // 店舗データのバリデーションチェック
            try validateShop(shop: shop)
            
            let realm = try Realm()
            let realmShop = RealmShop()
            realmShop.id = shop.id!
            realmShop.name = shop.name!
            realmShop.category = shop.category!
            realmShop.imageURL = shop.imageURL!
            realmShop.latitude = shop.latitude!
            realmShop.longitude = shop.longitude!
            realmShop.shopURL = shop.shopURL!
            
            // Realmへのオブジェクトの書き込み
            try realm.write {
                realm.create(RealmShop.self, value: realmShop, update: false)
            }
        } catch ShopValidateError.empty {
            print("Error: Shop Data is not right")
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
        }
    }
    
    /**
     保存した店舗数の取得処理
     
     - returns: 保存した店舗の数
     */
    func countShop() -> Int {
        do {
            let realm = try Realm()
            return realm.objects(RealmShop.self).count
        } catch _ as NSError {
            return 0
        }
    }
    
    /**
     保存した店舗全てを取得する処理
     
     - returns: 全ての店舗
     */
    func selectAll() -> Results<RealmShop>? {
        do {
            let realmShops = try Realm().objects(RealmShop.self)
            return realmShops
        } catch _ as NSError {
            return nil
        }
    }
    
    /**
     指定したIDの店舗を取得する処理
     
     - parameter id: 店舗ID
     - returns: 指定したIDに紐づく店舗
     */
    func selectById(_ id: String) -> Results<RealmShop>? {
        do {
            let realm = try Realm()
            let realmShop = realm.objects(RealmShop.self).filter("id == '\(id)'")
            if realmShop.count > 0 {
                return realmShop
            }
            return nil
        } catch _ as NSError {
            return nil
        }
    }
    
    /**
     指定したIDの店舗の存在チェック処理
     
     - parameter id: 店舗ID
     - returns: 存在チェック結果
     */
    func exsitsById(_ id: String) -> Bool {
        do {
            let realm = try Realm()
            let realmShop = realm.objects(RealmShop.self).filter("id == '\(id)'")
            if realmShop.count > 0 {
                return true
            } else {
                return false
            }
        } catch _ as NSError {
            return false
        }
    }
    
    /**
     指定したIDの店舗を削除する処理
     
     - parameter text: 足跡のタイトル
     */
    func delete(_ id: String) {
        if let realmShops = selectById(id) {
            do {
                let realm = try Realm()
                try realm.write {
                    for realmShop in realmShops {
                        realm.delete(realmShop)
                    }
                }
            } catch let error as NSError {
                print("Error: code - \(error.code), description - \(error.description)")
            }
        }
    }
    
    /**
     保存した全ての店舗を削除する処理
     */
    func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
        }
    }
    
    /**
     店舗データのバリデーションチェック
     
     - parameter shop: 店舗データ
     - throws: 不足店舗データがある場合にエラー
     */
    func validateShop(shop: HotpepperShop) throws {
        guard shop.id != nil else {
            throw ShopValidateError.empty
        }
        guard shop.name != nil else {
            throw ShopValidateError.empty
        }
        guard shop.category != nil else {
            throw ShopValidateError.empty
        }
        guard shop.imageURL != nil else {
            throw ShopValidateError.empty
        }
        guard shop.latitude != nil else {
            throw ShopValidateError.empty
        }
        guard shop.longitude != nil else {
            throw ShopValidateError.empty
        }
    }
}
