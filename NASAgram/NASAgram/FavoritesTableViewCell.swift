//
//  FavoritesTableViewCell.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/10/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

class FavoritesTableViewCell: UITableViewCell {
    
    static let identifier = "favoritesTableViewCell"
    
    private var imageHeight: CGFloat {
        return CGFloat(Int(bounds.width / 3))
    }
    private var imageWidth: CGFloat {
        return imageHeight * 1.5
    }
    private let edgeInsetHeight: CGFloat = 1
    private let titleLines = 3
    
    private var apodImageView = UIImageView()
    private var dateLabel = DetailLabel()
    private var titleLabel = DetailLabel()
    private var edgeInset = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
    }
    
    private func setupViews() {
        backgroundColor = .black
        apodImageView.contentMode = .scaleAspectFill
        apodImageView.clipsToBounds = true
        contentView.addSubview(apodImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleLabel)
        titleLabel.font = StyleManager.Font.system(size: .medium)
        titleLabel.numberOfLines = titleLines
        titleLabel.lineBreakMode = .byWordWrapping
        contentView.addSubview(edgeInset)
        edgeInset.backgroundColor = StyleManager.Color.accentLight
    }
    
    private func setupConstraints() {
        apodImageView.snp.makeConstraints { (view) in
            view.leading.top.equalToSuperview().offset(StyleManager.Dimension.standardMargin)
            view.bottom.equalToSuperview().offset(-StyleManager.Dimension.standardMargin)
            view.height.equalTo(imageHeight)
            view.width.equalTo(imageWidth)
        }
        dateLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(apodImageView.snp.trailing).offset(StyleManager.Dimension.standardMargin)
            view.top.equalTo(apodImageView)
            view.trailing.equalToSuperview().offset(-StyleManager.Dimension.standardMargin)
        }
        titleLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(dateLabel)
            view.top.equalTo(dateLabel.snp.bottom).offset(StyleManager.Dimension.standardMargin)
        }
        edgeInset.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(titleLabel)
            view.bottom.equalTo(apodImageView)
            view.height.equalTo(edgeInsetHeight)
        }
    }
    
    func configure(with apod: APOD) {
        dateLabel.text = apod.date.displayString()
        titleLabel.text = apod.title
        if let imageData = apod.ldImageData {
            apodImageView.image = UIImage(data: imageData as Data)
        } else {
            apodImageView.image = nil
        }
    }

}
