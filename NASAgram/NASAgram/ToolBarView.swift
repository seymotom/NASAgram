//
//  ToolBarView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class ToolBarView: UIView {
    
    var titleLabel = DetailLabel()
    var favoriteButton = UIButton()
    var optionsButton = UIButton()
    var dismissButton = UIButton()
    var dateSearchButton = UIButton()

    var delegate: APODInfoView!
    var vcType: APODVCType!
    
    let margin = 8.0
    
    var backgroundView: UIVisualEffectView!
    
    convenience init(delegate: APODInfoView, vcType: APODVCType) {
        self.init(frame: CGRect.zero)
        self.delegate = delegate
        self.vcType = vcType
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
        backgroundColor = .clear
        let effect = UIBlurEffect(style: .dark)
        backgroundView = UIVisualEffectView(effect: effect)
        addSubview(backgroundView)
        titleLabel.text = "NASAgram"
        titleLabel.contentMode = .center
        addSubview(titleLabel)
        favoriteButton.addTarget(delegate, action: #selector (delegate.favoriteButtonTapped(sender:)), for: .touchUpInside)
        favoriteButton.setTitle("☆", for: .normal)
        addSubview(favoriteButton)
        optionsButton.addTarget(delegate, action: #selector (delegate.optionsButtonTapped(sender:)), for: .touchUpInside)
        optionsButton.setTitle("🍔", for: .normal)
        addSubview(optionsButton)
        dateSearchButton.addTarget(delegate, action: #selector (delegate.dateSearchButtonTapped(sender:)), for: .touchUpInside)
        dateSearchButton.setTitle("🔍", for: .normal)
        addSubview(dateSearchButton)
        dismissButton.addTarget(delegate, action: #selector (delegate.dismissButtonTapped(sender:)), for: .touchUpInside)
        dismissButton.setTitle("✕", for: .normal)
        addSubview(dismissButton)
        
        switch vcType! {
        case .daily:
            dismissButton.isHidden = true
        case .favorite:
            dateSearchButton.isHidden = true
        }
    }
    
    func setupConstraints() {
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.top.equalToSuperview().offset(margin)
            view.bottom.equalToSuperview().offset(-margin)
        }
        
        optionsButton.snp.makeConstraints { (view) in
            view.leading.equalToSuperview().offset(margin)
            view.centerY.equalToSuperview()
        }
        
        favoriteButton.snp.makeConstraints { (view) in
            view.leading.equalTo(optionsButton.snp.trailing).offset(margin)
            view.centerY.equalToSuperview()
        }
        
        dateSearchButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().offset(-margin)
            view.centerY.equalToSuperview()
        }
        
        dismissButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().offset(-margin)
            view.centerY.equalToSuperview()
        }
        
    }
}
