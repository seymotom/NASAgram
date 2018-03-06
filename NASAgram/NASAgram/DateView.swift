//
//  DateView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit


class DateView: UIView {
    
    var dateLabel = DetailLabel()
    
    let backgroundView = BlurredBackgroundView(style: .dark)

    
    convenience init(date: Date) {
        self.init(frame: CGRect.zero)
        dateLabel.text = date.displayString().uppercased()
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
        dateLabel.font = StyleManager.Font.nasalization(size: .large)
        self.clipsToBounds = true
        self.layer.cornerRadius = StyleManager.Dimension.standardMargin
    }
    
    func setupConstraints() {
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { (view) in
            view.top.leading.equalToSuperview().offset(StyleManager.Dimension.standardMargin)
            view.trailing.bottom.equalToSuperview().offset(-StyleManager.Dimension.standardMargin)
        }
    }
}
