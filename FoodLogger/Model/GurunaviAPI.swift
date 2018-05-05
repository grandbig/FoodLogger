//
//  Gurunavi.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/18.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import CoreLocation
import Moya
import Alamofire
import SwiftyJSON
import PromiseKit

internal enum GurunaviAPITarget {
    case restaurants(lat: Double, lng: Double)
}

internal enum APIError: Error {
    case cancel
    case apiError(description: String)
    case decodeError
}

extension GurunaviAPITarget: TargetType {
    
    /// API Key
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "key", ofType: "plist") else {
            fatalError("key.plistが見つかりません")
        }
        
        guard let dic = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("key.plistの中身が想定通りではありません")
        }
        
        guard let apiKey = dic["gurunaviApiKey"] as? String else {
            fatalError("ぐるなびAPIのKeyが設定されていません")
        }
        
        return apiKey
    }
    
    // ベースURLを文字列で定義
    private var _baseURL: String {
        return "https://api.gnavi.co.jp/RestSearchAPI/20150630/"
    }
    
    public var baseURL: URL {
        return URL(string: _baseURL)!
    }
    
    // enumの値に対応したパスを指定
    public var path: String {
        switch self {
        case .restaurants:
            return ""
        }
    }
    
    // enumの値に対応したHTTPメソッドを指定
    public var method: Moya.Method {
        switch self {
        case .restaurants:
            return .get
        }
    }
    
    // スタブデータの設定
    public var sampleData: Data {
        switch self {
        case .restaurants:
            return "Stub data".data(using: String.Encoding.utf8)!
        }
    }
    
    // パラメータの設定
    var task: Task {
        switch self {
        case .restaurants(let lat, let lng):
            return .requestParameters(parameters: [
                "keyid": apiKey,
                "latitude": lat,
                "longitude": lng,
                "format": "json"
                ], encoding: URLEncoding.default)
        }
    }
    
    // ヘッダーの設定
    var headers: [String: String]? {
        switch self {
        case .restaurants:
            return nil
        }
    }
}

/**
 ぐるなびAPI
 */
class GurunaviAPI {
    
    private var provider: MoyaProvider<GurunaviAPITarget>!
    
    /// イニシャライザ
    init() {
        provider = MoyaProvider<GurunaviAPITarget>()
    }
    
    /// ぐるなびレストラン検索API
    ///
    /// - Parameter coordinate: 位置
    /// - Returns: レストラン情報
    func searchRestaurant(coordinate: CLLocationCoordinate2D)  -> Promise<Restaurants> {
        let (promise, resolver) = Promise<Restaurants>.pending()

        provider.request(.restaurants(lat: coordinate.latitude, lng: coordinate.longitude)) { result in
            switch result {
            case .success(let response):
                do {
                    var result = Restaurants(rest: [], totalHitCount: "", hitPerPage: "", pageOffset: "")
                    let rest = JSON(response.data)["rest"]
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let restaurants = try decoder.decode(Restaurants.self, from: response.data)
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
                    resolver.reject(APIError.decodeError)
                }
            case .failure(let error):
                resolver.reject(APIError.apiError(description: error.localizedDescription))
            }
        }
        return promise
    }
}
