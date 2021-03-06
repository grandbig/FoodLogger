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
    func searchRestaurant(coordinate: CLLocationCoordinate2D, completion: @escaping ((JSON) -> Void)) {
        let requestURL = "\(baseURL)&keyid=\(String(describing: self.apiKey))&format=json"
        let parameters = ["keyid": self.apiKey, "format": "json", "latitude": coordinate.latitude, "longitude": coordinate.longitude] as [String : Any]
        Alamofire.request(requestURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            let json = JSON(response.result.value as Any)
            let result = json["rest"]
            
            completion(result)
        }
    }
}
