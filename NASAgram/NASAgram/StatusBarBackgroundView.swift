//
//  StatusBarBackgroundView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class StatusBarBackgroundView: UIView {
    
    var backgroundView: UIVisualEffectView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        let effect = UIBlurEffect(style: .dark)
        backgroundView = UIVisualEffectView(effect: effect)
        addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    
}
