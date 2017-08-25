//
//  Extension+UIView.swift
//  NASAgram
//
//  Created by Tom Seymour on 8/25/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

extension UIVisualEffectView {
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
