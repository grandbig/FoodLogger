//
//  CustomGMSMarker.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/09/23.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import GoogleMaps

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
