//
//  ToolBarView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

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
    let backgroundView = BlurredBackgroundView(style: .dark)

    var delegate: ToolBarViewDelegate!
    var pageViewType: APODPageViewType!
    
    
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
        titleLabel.font = StyleManager.Font.nasalization()
        titleLabel.text = StyleManager.Text.appTitle
        titleLabel.contentMode = .center
        titleLabel.clipsToBounds = false
        addSubview(titleLabel)
        favoriteButton.addTarget(delegate, action: #selector (delegate.favoriteButtonTapped(sender:)), for: .touchUpInside)
        favoriteButton.setImage(StyleManager.Icon.favoriteEmpty, for: .normal)
        addSubview(favoriteButton)
        optionsButton.addTarget(delegate, action: #selector (delegate.optionsButtonTapped(sender:)), for: .touchUpInside)
        optionsButton.setImage(StyleManager.Icon.share, for: .normal)
        optionsButton.imageEdgeInsets = StyleManager.Icon.shareEdgeInset
        addSubview(optionsButton)
        dateSearchButton.addTarget(delegate, action: #selector (delegate.dateSearchButtonTapped(sender:)), for: .touchUpInside)
        dateSearchButton.setImage(StyleManager.Icon.search, for: .normal)
//        dateSearchButton.imageEdgeInsets = StyleManager.Icon.searchEdgeInset
        addSubview(dateSearchButton)
        dismissButton.addTarget(delegate, action: #selector (delegate.dismissButtonTapped(sender:)), for: .touchUpInside)
        dismissButton.setImage(StyleManager.Icon.dismiss, for: .normal)
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
        }
        
        optionsButton.snp.makeConstraints { (view) in
            view.leading.equalToSuperview().offset(StyleManager.Dimension.standardMargin)
            view.centerY.equalToSuperview()
        }
        
        favoriteButton.snp.makeConstraints { (view) in
            view.leading.equalTo(optionsButton.snp.trailing).offset(StyleManager.Dimension.standardMargin)
            view.centerY.equalToSuperview()
        }
        
        dateSearchButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().offset(-StyleManager.Dimension.standardMargin)
            view.centerY.equalToSuperview()
        }
        
        dismissButton.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().offset(-StyleManager.Dimension.standardMargin)
            view.centerY.equalToSuperview()
        }
    }
    
    func setFavorite(_ isFavorite: Bool) {
        let iconImage = isFavorite ? StyleManager.Icon.favoriteFilled : StyleManager.Icon.favoriteEmpty
        let tintedIconImage = iconImage?.withRenderingMode(.alwaysTemplate)
        favoriteButton.setImage(tintedIconImage, for: .normal)
        favoriteButton.tintColor = isFavorite ? StyleManager.Color.favoriteGold : StyleManager.Color.primary
    }
}
