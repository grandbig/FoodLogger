//
//  UnwindFadeSegue.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/07/30.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class UnwindFadeSegue: UIStoryboardSegue {
    
    override func perform() {
        UIView.transition(
            with: (source.navigationController?.view)!,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                () -> Void in
                self.source.navigationController?.popToViewController(self.destination, animated: false)
        },
            completion: nil)
    }
    
}
