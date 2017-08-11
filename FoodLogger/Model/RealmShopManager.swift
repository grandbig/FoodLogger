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
     ショップ情報をRealmに保存する処理
     
     - parameter shop: ショップデータ
     - parameter rating: 評価
     - parameter images: 画像データリスト
     - parameter memo: メモ
     */
    func createShop(shop: HotpepperShop, rating: Int?, images: [Data]?, memo: String?) {
        do {
            // ショップデータのバリデーションチェック
            try validateShop(shop: shop)
            
            let realm = try Realm()
            let realmShop = RealmShop()
            
            // 保存必須項目
            realmShop.id = shop.id!
            realmShop.name = shop.name!
            realmShop.category = shop.category!
            realmShop.imageURL = shop.imageURL!
            realmShop.latitude = shop.latitude!
            realmShop.longitude = shop.longitude!
            realmShop.shopURL = shop.shopURL!
            
            // 評価が指定されている場合
            if let shopRating = rating {
                realmShop.rating = shopRating
            }
            // メモが指定されている場合
            if let shopMemo = memo {
                realmShop.memo = shopMemo
            }
            // 画像が指定されている場合
            if let foodImages = images {
                let foods = List<RealmFood>()
                for image in foodImages {
                    let realmFood = RealmFood()
                    realmFood.imageData = image
                    foods.append(realmFood)
                }
                realmShop.foods.append(objectsIn: foods)
            }
            
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
     Realmに保存したショップ情報を更新する処理
     
     - parameter id: ショップID
     - parameter rating: 評価
     - parameter memo: メモ
     - parameter images: 画像データリスト
     */
    func updateShop(id: String, rating: Int?, memo: String?, images: [Data]?) {
        do {
            let realm = try Realm()
            let shop = realm.objects(RealmShop.self).filter("id == '\(id)'")
            try realm.write {
                // 評価が指定されている場合
                if let shopRating = rating {
                    shop.setValue(shopRating, forKey: "rating")
                }
                // メモが指定されている場合
                if let shopMemo = memo {
                    shop.setValue(shopMemo, forKey: "memo")
                }
                // 画像が指定されている場合
                if let foodImages = images {
                    // 画像の入れ替え処理
                    realm.delete(shop[0].foods)
                    let foods = List<RealmFood>()
                    for image in foodImages {
                        let realmFood = RealmFood()
                        realmFood.imageData = image
                        foods.append(realmFood)
                    }
                    shop.setValue(foods, forKey: "foods")
                }
                // 更新日時の更新
                shop.setValue(Date().timeIntervalSince1970, forKey: "updated")
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
        }
    }
    
    /**
     保存したショップ数の取得処理
     
     - returns: 保存したショップの数
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
     保存したショップ全てを取得する処理
     
     - returns: 全てのショップ
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
     指定したIDのショップを取得する処理
     
     - parameter id: ショップID
     - returns: 指定したIDに紐づくショップ
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
     指定したIDのショップの存在チェック処理
     
     - parameter id: ショップID
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
     保存した食品全てを取得する処理
     
     - returns: 全ての食品
     */
    func selectAllFoods() -> Results<RealmFood>? {
        do {
            let realmFoods = try Realm().objects(RealmFood.self)
            return realmFoods
        } catch _ as NSError {
            return nil
        }
    }
    
    /**
     指定したIDのショップを削除する処理
     
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
     保存した全てのショップを削除する処理
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
     指定したIDの食品オブジェクトを削除する処理
     
     - parameter id: ショップID
     */
    func deleteImage(id: String) {
        guard let shop = self.selectById(id) else {
            return
        }
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(shop[0].foods)
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
        }
    }
    
    /**
     ショップデータのバリデーションチェック
     
     - parameter shop: ショップデータ
     - throws: 不足ショップデータがある場合にエラー
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
