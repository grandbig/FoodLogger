//
//  MapViewInteractor.swift
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

protocol MapViewBusinessLogic {
    func fetchMyShop(request: MapView.FetchMyShop.Request)
    func fetchAroundShop(request: MapView.FetchAroundShop.Request)
    func selectShop(request: MapView.SelectShop.Request)
}

protocol MapViewDataStore {
    var selectedShop: HotpepperShop { get set }
    var myLocation: CLLocation { get set }
}

class MapViewInteractor: MapViewBusinessLogic, MapViewDataStore {
    
    var presenter: MapViewPresentationLogic?
    var worker = ShopsWorker(dataStore: RealmShopManager.sharedInstance)
    var mapViewWorker: MapViewWorker?
    var selectedShop = HotpepperShop()
    var myLocation = CLLocation()
    
    var myShops: [MyShop]?
    var searchedShops: [HotpepperShop]?
  
    // MARK: Fetch my shop
    func fetchMyShop(request: MapView.FetchMyShop.Request) {
        worker.fetchShops { (shops) in
            if shops != nil {
                self.myShops = shops
            }
            let response = MapView.FetchMyShop.Response(shops: shops)
            self.presenter?.presentFetchedMyShops(response: response)
        }
    }
    
    // MARK: Fetch around shop
    func fetchAroundShop(request: MapView.FetchAroundShop.Request) {
        mapViewWorker = MapViewWorker()
        mapViewWorker?.searchShop(latitude: request.latitude, longitude: request.longitude, success: { (shops) in
            if self.myShops != nil {
                for shop in shops {
                    for myShop in request.myShops where shop.id != myShop.id {
                        self.searchedShops?.append(shop)
                    }
                }
            } else {
                self.searchedShops = shops
            }
            
            let response = MapView.FetchAroundShop.Response(shops: self.searchedShops)
            self.presenter?.presentFetchedAroundShops(response: response)
        }, failure: { (error) in
            // TODO: どうする？
        })
    }
    
    // MARK: Select one shop
    func selectShop(request: MapView.SelectShop.Request) {
        self.selectedShop = request.shop
        self.myLocation = CLLocation(latitude: request.latitude, longitude: request.longitude)
        let response = MapView.SelectShop.Response()
        self.presenter?.presentSelectedShop(response: response)
    }
}
