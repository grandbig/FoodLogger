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

class CustomGMSMarker: GMSMarker {
    /// マーカID
    public var id: String?
    
    /// 初期化
    override init() {
        super.init()
    }
    
    /**
     マーカの位置を設定する処理
     
     - parameter position:　位置
     */
    func setMarkerPosition(_ position: CLLocationCoordinate2D) {
        self.position = position
    }
    
    /**
     マーカのIDを設定する処理
     
     - parameter id: マーカのID
     */
    func setMarkerID(_ id: String) {
        self.id = id
    }
}
