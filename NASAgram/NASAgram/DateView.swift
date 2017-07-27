//
//  DateView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class DateView: UIView {
    
    let margin = 20.0
    
    var dateLabel = DetailLabel()
    
    let backgroundView = BlurredBackgroundView(style: .dark)
    
    convenience init(date: Date) {
        self.init(frame: CGRect.zero)
        dateLabel.text = date.displayString()
        setup()
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func setup() {
        setupViews()
        setupConstraints()
    }
    
    
    func setupViews() {
        addSubview(backgroundView)
        addSubview(dateLabel)
        dateLabel.textAlignment = .center
    }
    
    func setupConstraints() {
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { (view) in
            view.top.leading.equalToSuperview().offset(margin)
            view.trailing.equalToSuperview().offset(-margin)
        }
    }
    
    
    
}
