//
//  RealmShopManager.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/22.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift
import SwiftyJSON

class RealmShopManager: ShopsProtocol {
    
    /// シングルトン
    static let sharedInstance = RealmShopManager()
    
    /// イニシャライザ
    init() {
    }
    
    // MARK: CRUD operations
    func fetchShops(completionHandler: @escaping ([MyShop]?) -> Void) {
        var shops: [MyShop]?
        do {
            let realmShops = try Realm().objects(RealmShop.self)
            if realmShops.count > 0 {
                for realmShop in realmShops {
                    let coordinate = CLLocationCoordinate2D.init(latitude: realmShop.latitude, longitude: realmShop.longitude)
                    let shop = MyShop(id: realmShop.id, name: realmShop.name, category: realmShop.category, imageURL: realmShop.imageURL, coordinate: coordinate, shopURL: realmShop.shopURL, rating: realmShop.rating)
                    shops?.append(shop)
                }
            }
            completionHandler(shops)
        } catch _ as NSError {
            completionHandler(shops)
        }
    }
    
    func fetchShop(id: String, completionHandler: @escaping (MyShop?) -> Void) {
        var shop: MyShop?
        do {
            let realm = try Realm()
            let realmShops = realm.objects(RealmShop.self).filter("id == '\(id)'")
            if realmShops.count > 0, let realmShop = realmShops.first {
                let coordinate = CLLocationCoordinate2D.init(latitude: realmShop.latitude, longitude: realmShop.longitude)
                shop = MyShop(id: realmShop.id, name: realmShop.name, category: realmShop.category, imageURL: realmShop.imageURL, coordinate: coordinate, shopURL: realmShop.shopURL, rating: realmShop.rating)
            }
            completionHandler(shop)
        } catch _ as NSError {
            completionHandler(shop)
        }
    }
    
    func createShop(shop: MyShop, images: [Data]?, mealTime: Int, memo: String?, completionHandler: @escaping () -> Void) {
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
            realmShop.latitude = shop.coordinate!.latitude
            realmShop.longitude = shop.coordinate!.longitude
            realmShop.shopURL = shop.shopURL!
            realmShop.mealTime = mealTime
            
            // 評価が指定されている場合
            if let shopRating = shop.rating {
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
                completionHandler()
            }
        } catch ShopValidateError.empty {
            print("Error: Shop Data is not right")
            completionHandler()
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
            completionHandler()
        }
    }
    
    func updateShop(id: String, rating: Int?, images: [Data]?, mealTime: Int, memo: String?, completionHandler: @escaping () -> Void) {
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
                if let images = images {
                    // 画像の入れ替え処理
                    realm.delete(shop[0].foods)
                    
                    let foods = images.map { (image) -> RealmFood in
                        let food = RealmFood()
                        food.imageData = image
                        return realm.create(RealmFood.self, value: food, update: true)
                    }
                    shop[0].foods.append(objectsIn: foods)
                }
                // 食事種別の更新
                shop.setValue(mealTime, forKey: "mealTime")
                // 更新日時の更新
                shop.setValue(Date().timeIntervalSince1970, forKey: "updated")
                completionHandler()
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
            completionHandler()
        }
    }
    
    func deleteShops(completionHandler: @escaping () -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
                completionHandler()
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
            completionHandler()
        }
    }
    
    func deleteShop(id: String, completionHandler: @escaping () -> Void) {
        do {
            let realm = try Realm()
            let realmShops = realm.objects(RealmShop.self).filter("id == '\(id)'")
            try realm.write {
                for realmShop in realmShops {
                    realm.delete(realmShop)
                }
                completionHandler()
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
            completionHandler()
        }
    }
    
    // MARK: Other operations
    // TODO: 削除予定
    func selectAll() -> Results<RealmShop>? {
        do {
            let realmShops = try Realm().objects(RealmShop.self)
            return realmShops
        } catch _ as NSError {
            return nil
        }
    }
    
    
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
     ショップデータのバリデーションチェック
     
     - parameter shop: ショップデータ
     - throws: 不足ショップデータがある場合にエラー
     */
    func validateShop(shop: MyShop) throws {
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
        guard shop.coordinate?.latitude != nil else {
            throw ShopValidateError.empty
        }
        guard shop.coordinate?.longitude != nil else {
            throw ShopValidateError.empty
        }
    }
}

/**
 ショップデータのバリデーションエラー
 */
enum ShopValidateError: Error {
    case empty
    case unknown(String)
}
