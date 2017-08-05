//
//  CustomCollectionViewCell.swift
//  FoodLogger
//
//  Created by Takahiro Kato on 2017/08/06.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibViewSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.xibViewSet()
    }
    
    internal func xibViewSet() {
        if let view = Bundle.main.loadNibNamed("CustomCollectionViewCell", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    /*
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
*/
}
