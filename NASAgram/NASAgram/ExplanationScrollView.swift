//
//  ExplanationScrollView.swift
//  NASAgram
//
//  Created by Tom Seymour on 8/24/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class ExplanationScrollView: UIScrollView {
    
    var explanationLabel = DetailLabel()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
       addSubview(explanationLabel)
        explanationLabel.font = UIFont.systemFont(ofSize: 12)
        explanationLabel.numberOfLines = 0
        explanationLabel.lineBreakMode = .byWordWrapping
    }
    
    private func setupConstraints() {
        explanationLabel.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
            view.width.centerX.equalToSuperview()
        }
    }
}
