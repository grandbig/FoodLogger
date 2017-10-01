//
//  ShopsWorker.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/09/23.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class ShopsWorker {
    var dataStore: ShopsProtocol
    
    init(dataStore: ShopsProtocol) {
        self.dataStore = dataStore
    }
    
    func fetchShops(completionHandler: @escaping ([MyShop]?) -> Void) {
        dataStore.fetchShops { (shops) in
            DispatchQueue.main.async {
                completionHandler(shops)
            }
        }
    }
    
    func fetchShop(id: String, completionHandler: @escaping (MyShop?) -> Void) {
        dataStore.fetchShop(id: id) { (shop) in
            DispatchQueue.main.async {
                completionHandler(shop)
            }
        }
    }
    
    func createShop(shop: MyShop, completionHandler: @escaping () -> Void) {
        dataStore.createShop(shop: shop) {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    func updateShop(id: String, rating: Int?, images: [UIImage]?, mealTime: Int, memo: String?, completionHandler: @escaping () -> Void) {
        dataStore.updateShop(id: id, rating: rating, images: images, mealTime: mealTime, memo: memo) {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    func deleteShops(completionHandler: @escaping () -> Void) {
        dataStore.deleteShops {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    func deleteShop(id: String, completionHandler: @escaping () -> Void) {
        dataStore.deleteShop(id: id) {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}

protocol ShopsProtocol {
    
    // MARK: CRUD operations
    /**
     保存したショップ全てを取得する処理
     
     - returns: 全てのショップ
     */
    func fetchShops(completionHandler: @escaping ([MyShop]?) -> Void)
    
    /**
     指定したIDのショップを取得する処理
     
     - parameter id: ショップID
     - returns: 指定したIDに紐づくショップ
     */
    func fetchShop(id: String, completionHandler: @escaping (MyShop?) -> Void)
    
    /**
     ショップ情報をRealmに保存する処理
     
     - parameter shop: ショップデータ
     */
    func createShop(shop: MyShop, completionHandler: @escaping () -> Void)
    
    /**
     Realmに保存したショップ情報を更新する処理
     
     - parameter id: ショップID
     - parameter rating: 評価
     - parameter images: 画像データリスト
     - parameter mealTIme: 食事種別
     - parameter memo: メモ
     */
    func updateShop(id: String, rating: Int?, images: [UIImage]?, mealTime: Int, memo: String?, completionHandler: @escaping () -> Void)
    
    /**
     保存した全てのショップを削除する処理
     */
    func deleteShops(completionHandler: @escaping () -> Void)
    
    /**
     指定したIDのショップを削除する処理
     
     - parameter text: 足跡のタイトル
     */
    func deleteShop(id: String, completionHandler: @escaping () -> Void)
}
