//
//  ShopValidateError.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/22.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation

/**
 店舗データのバリデーションエラー
 */
enum ShopValidateError: Error {
    case Empty
    case Unknown(String)
}
