//
//  ToolBarView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

@objc protocol ToolBarViewDelegate {
    func favoriteButtonTapped(sender: UIButton)
    func optionsButtonTapped(sender: UIButton)
    func dateSearchButtonTapped(sender: UIButton)
    func dismissButtonTapped(sender: UIButton)
}

class ToolBarView: UIView {
    
    var titleLabel = DetailLabel()
    var favoriteButton = UIButton()
    var optionsButton = UIButton()
    var dismissButton = UIButton()
    var dateSearchButton = UIButton()

    var delegate: ToolBarViewDelegate!
    var pageViewType: APODPageViewType!
    
    static let height: CGFloat = 50.0
    let margin = 8.0
    
    let backgroundView = BlurredBackgroundView(style: .dark)
    
    convenience init(delegate: ToolBarViewDelegate, pageViewType: APODPageViewType) {
        self.init(frame: CGRect.zero)
        self.delegate = delegate
        self.pageViewType = pageViewType
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
        
        switch pageViewType! {
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
    
    func setFavorite(_ isFavorite: Bool) {
        favoriteButton.setTitle(isFavorite ? "⭐️" : "☆", for: .normal)
    }
}
