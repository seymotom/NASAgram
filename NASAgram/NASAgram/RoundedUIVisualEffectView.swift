////
////  RoundedUIVisualEffectView.swift
////  NASAgram
////
////  Created by Tom Seymour on 8/25/17.
////  Copyright © 2017 seymotom. All rights reserved.
////
//
//import UIKit
//
//class RoundedUIVisualEffectView: UIVisualEffectView {
//    
//    var roundedCorners: UIRectCorner = []
//    
//    override public func layoutSubviews() {
//        super.layoutSubviews()
//        round(corners: roundedCorners, radius: 20)
//    }
//
//    convenience init(effect: UIVisualEffect?, roundedCorners: UIRectCorner) {
//        self.init(effect: effect)
//        self.roundedCorners = roundedCorners
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//    }
//    
//    override init(effect: UIVisualEffect?) {
//        super.init(effect: effect)
//    }
//}
