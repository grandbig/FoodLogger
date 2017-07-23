//
//  MarkerType.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/23.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation

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
