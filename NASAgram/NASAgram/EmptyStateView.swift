//
//  EmptyStateView.swift
//  NASAgram
//
//  Created by Tom Seymour on 10/14/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {
    
    let textLabel = DetailLabel()
    let backgroundImageView = UIImageView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    private func setup() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        backgroundImageView.image = StyleManager.Image.background
        backgroundImageView.alpha = 0.3
        backgroundImageView.contentMode = .scaleAspectFit
        textLabel.numberOfLines = 0
        textLabel.contentMode = .center
        textLabel.text = StyleManager.Text.emptyStateText
        textLabel.font = StyleManager.Font.nasalization()   
        addSubview(backgroundImageView)
        addSubview(textLabel)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (view) in
            view.top.bottom.centerX.equalToSuperview()
        }
        textLabel.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
        }
    }
}
