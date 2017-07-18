//
//  FavoritesTableViewCell.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/10/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    static let identifier = "favoritesTableViewCell"
    
    let margin = 8.0
    var imageHeight: CGFloat {
        return CGFloat(Int(bounds.width / 3))
    }
    
    var apodImageView = UIImageView()
    var dateLabel = DetailLabel()
    var titleLabel = DetailLabel()
    var edgeInset = UIView()
    
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
//        super.setSelected(selected, animated: animated)

    }
    
    private func setupViews() {
        backgroundColor = .black
        apodImageView.contentMode = .scaleAspectFill
        apodImageView.clipsToBounds = true
        addSubview(apodImageView)
        addSubview(dateLabel)
        addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        addSubview(edgeInset)
        edgeInset.backgroundColor = .white
    }
    
    private func setupConstraints() {
        apodImageView.snp.makeConstraints { (view) in
            view.leading.top.equalToSuperview().offset(margin)
            view.bottom.equalToSuperview().offset(-margin)
            view.height.equalTo(imageHeight)
            view.width.equalTo(imageHeight * 1.5)
        }
        dateLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(apodImageView.snp.trailing).offset(margin)
            view.top.equalTo(apodImageView)
            view.trailing.equalToSuperview().offset(-margin)
        }
        titleLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(dateLabel)
            view.top.equalTo(dateLabel.snp.bottom).offset(margin)
        }
        
        edgeInset.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(titleLabel)
            view.bottom.equalTo(apodImageView)
            view.height.equalTo(1)
        }
    }
    
    func configure(with apod: APOD) {
        dateLabel.text = apod.date.displayString()
        titleLabel.text = apod.title
        apodImageView.image = apod.mediaType == .image ? UIImage(data: apod.ldImageData! as Data) : #imageLiteral(resourceName: "Video-Icon")
    }

}
