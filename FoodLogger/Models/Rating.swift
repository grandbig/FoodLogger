//
//  Rating.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/08/12.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation

class Rating {
    
    /// イニシャライザ
    init() {
    }
    
    /**
     評価数値を★の数に変換する処理
     
     - parameter rating: 評価数値
     - returns: ★数
     */
    func changeRatingValue(rating: Int) -> String {
        switch rating {
        case 1:
            return "★"
        case 2:
            return "★★"
        case 3:
            return "★★★"
        case 4:
            return "★★★★"
        case 5:
            return "★★★★★"
        default:
            return ""
        }
    }
}
