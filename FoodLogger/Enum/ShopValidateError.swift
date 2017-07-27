//
//  ShopValidateError.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/22.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation

/**
 ショップデータのバリデーションエラー
 */
enum ShopValidateError: Error {
    case empty
    case unknown(String)
}
