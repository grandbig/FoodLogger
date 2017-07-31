//
//  RequestListViewModel.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/31.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond
import SwiftyJSON
import CoreLocation

/// 通信の各状態をEnumで表現
enum RequestState {
    case none
    case requesting
    case finish
    case error
}

enum RequestError: Error {
    case none
    case network
    case other
}

/// HOtpepperAPIのViewModelクラス
final class HotpepperAPIViewModel {
    
    var items: ObservableArray<JSON> = ObservableArray([])
    let requestState = Observable<RequestState>(.none)
    let requestError = Observable<RequestError>(.none)
    let hotpepperAPI = HotpepperAPI.init()
    
    var isLoadingViewAnimate: Signal<Bool, NoError> {
        return self.requestState.map { $0 == .requesting }
    }
    
    var isLoadingViewHidden: Signal<Bool, NoError> {
        return self.requestState.map { $0 != .requesting }
    }
    
    var finishSearchRestaurant: Signal<[JSON]?, NoError> {
        return self.requestState.map({ (requestState) -> [JSON]? in
            if requestState == .finish {
                return self.items.array
            }
            return nil
        })
    }
    
    func searchRestaurant(coordinate: CLLocationCoordinate2D) {
        self.requestState.next(RequestState.requesting)
        hotpepperAPI.searchRestaurant(coordinate: coordinate, success: { (result) in
            guard let resultArray = result.array else {
                self.requestState.next(RequestState.error)
                return
            }
            self.items = ObservableArray(resultArray)
            self.requestState.next(RequestState.finish)
        }) { (error) in
            self.requestState.next(RequestState.error)
        }
    }
}
