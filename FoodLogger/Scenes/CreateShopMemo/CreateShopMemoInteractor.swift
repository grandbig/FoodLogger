//
//  CreateShopMemoInteractor.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/09/24.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import CoreLocation

protocol CreateShopMemoBusinessLogic {
    func fetchShopStatus(request: CreateShopMemo.FetchShopStatus.Request)
    func createMyShop(request: CreateShopMemo.CreateMyShop.Request)
    func updateMyShop(request: CreateShopMemo.UpdateMyShop.Request)
    func uploadImage(request: CreateShopMemo.UploadImage.Request)
}

protocol CreateShopMemoDataStore {
    var shop: HotpepperShop! { get set }
    var location: CLLocation! { get set }
}

class CreateShopMemoInteractor: CreateShopMemoBusinessLogic, CreateShopMemoDataStore {
    
    var presenter: CreateShopMemoPresentationLogic?
    var worker = ShopsWorker(dataStore: RealmShopManager.sharedInstance)
    var shop: HotpepperShop!
    var location: CLLocation!
    
    // MARK: Fetch shop status
    
    func fetchShopStatus(request: CreateShopMemo.FetchShopStatus.Request) {
        worker.fetchShop(id: shop.id ?? "0") { (shop) in
            let response = CreateShopMemo.FetchShopStatus.Response(shop: shop)
            self.presenter?.presentShopStatus(response: response)
        }
    }
    
    // MARK: Create my shop
    func createMyShop(request: CreateShopMemo.CreateMyShop.Request) {
        let myShop = shop as! MyShop
        let myCoordinate = location.coordinate
        if let shopCoordinate = myShop.coordinate, getDistance(from: shopCoordinate, to: myCoordinate) > 500 {
            // 現在地がショップから離れすぎている場合
            let response = CreateShopMemo.CreateMyShop.Response(isSaved: false, message: "ショップに近づいて再度お試しください")
            presenter?.presentCreatedMyShop(response: response)
        }
        
        myShop.rating = request.rating
        myShop.memo = request.memo
        myShop.mealTime = request.mealTime
        myShop.foodImages = request.images
        
        worker.createShop(shop: myShop) {
            let response = CreateShopMemo.CreateMyShop.Response(isSaved: true, message: nil)
            self.presenter?.presentCreatedMyShop(response: response)
        }
    }
    
    // MARK: Update my shop
    func updateMyShop(request: CreateShopMemo.UpdateMyShop.Request) {
        
    }
    
    // MARK: Upload image
    func uploadImage(request: CreateShopMemo.UploadImage.Request) {
        
    }
    
    // MARK: Other
    /**
     2点間の距離を取得
     
     - parameter from: 1つ目の位置情報
     - parameter to: 2つ目の位置情報
     - returns: 2点間の距離 (単位は [m] )
     */
    private func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: to.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return toLocation.distance(from: fromLocation)
    }
}
