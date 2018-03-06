//
//  BlurredBackgroundView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

class BlurredBackgroundView: UIView {
    
    private var backgroundView: UIVisualEffectView!
    private var style: UIBlurEffectStyle!
    
    convenience init(style: UIBlurEffectStyle = .dark) {
        self.init(frame: CGRect.zero)
        self.style = style
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func setup() {
        addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}
