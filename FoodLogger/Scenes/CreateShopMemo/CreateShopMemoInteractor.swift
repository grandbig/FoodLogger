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
    
    // MARK: Do something
    
    func fetchShopStatus(request: CreateShopMemo.FetchShopStatus.Request) {
        worker.fetchShop(id: shop.id ?? "0") { (shop) in
            let response = CreateShopMemo.FetchShopStatus.Response(shop: shop)
            self.presenter?.presentShopStatus(response: response)
        }
    }
}
