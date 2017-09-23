//
//  CustomGMSMarker.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/19.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON

/**
 マーカタイプ
 */
enum MarkerType: Int {
    case searched = 0
    case saved
    
    static let defaultMarkerType = MarkerType.searched
    init() {
        self = MarkerType.defaultMarkerType
    }
}

/**
 GMSMarkerのカスタムクラス
 */
class CustomGMSMarker: GMSMarker {
    /// マーカID
    public var id: String?
    /// ショップ名
    public var shopName: String?
    /// カテゴリ名
    public var categoryName: String?
    /// 評価数
    public var rating: Int?
    /// 画像URL
    public var imageURL: String?
    /// ショップURL
    public var shopURL: String?
    /// マーカタイプ
    public var type: MarkerType?
    
    /// 初期化
    override init() {
        super.init()
    }
}

/**
 ホットペッパーAPI
 */
class HotpepperAPI {
    /// API Key
    private var apiKey: String = String()
    /// Geocoding APIのベースURL
    private let baseURL: String = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    
    /// 初期化処理
    init() {
        if let path = Bundle.main.path(forResource: "key", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let apiKey = dic["hotpepperApiKey"] as? String {
                    self.apiKey = apiKey
                }
            }
        }
    }
    
    /**
     ホットペッパーグルメサーチAPI
     
     - parameter coordinate: 位置
     - parameter success: レストラン情報を返却するcallback
     - parameter failure: エラー情報を返却するcallback
     */
    func searchRestaurant(coordinate: CLLocationCoordinate2D, success: @escaping ((JSON) -> Void), failure: @escaping ((Error) -> Void)) {
        let parameters = ["key": self.apiKey, "format": "json", "lat": coordinate.latitude, "lng": coordinate.longitude, "range": 3] as [String : Any]
        Alamofire.SessionManager.default.requestWithoutCache(baseURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            if response.result.isFailure {
                failure(response.result.error!)
                return
            }
            let json = JSON(response.result.value as Any)
            let result = json["results"]["shop"]
            
            success(result)
        }
    }
}

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

extension Alamofire.SessionManager {
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest {
            do {
                var urlRequest = try URLRequest(url: url, method: method, headers: headers)
                urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
                let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
                return request(encodedURLRequest)
            } catch {
                print(error)
                return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
            }
    }
}
