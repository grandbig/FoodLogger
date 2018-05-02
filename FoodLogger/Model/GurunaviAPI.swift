//
//  Gurunavi.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/18.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON
import PromiseKit

/**
 ぐるなびAPI
 */
class GurunaviAPI {
    
    /// API Key
    private var apiKey: String = String()
    /// Geocoding APIのベースURL
    private let baseURL: String = "https://api.gnavi.co.jp/RestSearchAPI/20150630/"
    
    /// 初期化処理
    init() {
        if let path = Bundle.main.path(forResource: "key", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let apiKey = dic["gurunaviApiKey"] as? String {
                    self.apiKey = apiKey
                }
            }
        }
    }
    
    /**
     ぐるなびレストラン検索API
     
     - parameter coordinate: 位置
     - parameter completion: レストラン情報を返却するcallback
     */
    func searchRestaurant(coordinate: CLLocationCoordinate2D)  -> Promise<Restaurants> {
        let (promise, resolver) = Promise<Restaurants>.pending()

        let requestURL = "\(baseURL)&keyid=\(String(describing: self.apiKey))&format=json"
        let parameters = ["keyid": self.apiKey, "format": "json", "latitude": coordinate.latitude, "longitude": coordinate.longitude] as [String: Any]
        Alamofire.request(requestURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .response { response in
                do {
                    var result = Restaurants(rest: [], totalHitCount: "", hitPerPage: "", pageOffset: "")

                    guard let data = response.data else {
                        return
                    }
                    let rest = JSON(data)["rest"]
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let restaurants = try decoder.decode(Restaurants.self, from: data)
                    guard let array = rest.array else {
                        resolver.fulfill(restaurants)
                        return
                    }
                    for elem in array {
                        for restaurant in restaurants.rest where restaurant.id == elem["id"].string {
                            var convertedRestaurant = restaurant
                            convertedRestaurant.shopImage1 = elem["image_url"]["shop_image1"].string
                            convertedRestaurant.shopImage2 = elem["image_url"]["shop_image2"].string
                            result.rest.append(convertedRestaurant)
                            break
                        }
                    }
                    
                    resolver.fulfill(result)
                } catch {
                    resolver.reject(error)
                }
        }
        return promise
    }
}
