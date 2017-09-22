//
//  DetailView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

protocol DetailViewDelegate {
    func videoButtonTapped()
}


class DetailView: UIView {
    
    var delegate: DetailViewDelegate!
    
    let margin: CGFloat = 11.0

    var titleLabel = DetailLabel()
    var explanationScrollView = ExplanationScrollView()
    var copyrightLabel = DetailLabel()
    
    var videoPlayView = VideoPlayView()
    
    let backgroundView = BlurredBackgroundView(style: .dark)
        
    convenience init(delegate: DetailViewDelegate) {
        self.init(frame: CGRect.zero)
        self.delegate = delegate
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
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        
        addSubview(titleLabel)
        
        addSubview(explanationScrollView)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = margin
    }
    
    func setupConstraints() {
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (view) in
            view.top.leading.equalToSuperview().offset(margin)
            view.trailing.equalToSuperview().offset(-margin)
        }
        explanationScrollView.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(titleLabel)
            view.top.equalTo(titleLabel.snp.bottom).offset(margin)
            view.bottom.equalToSuperview().offset(-margin)
        }
    }
    
    func populateInfo(from apod: APOD) {
        titleLabel.text = apod.title
        explanationScrollView.explanationLabel.text = apod.explanation
        
        if let copyright = apod.copyright {
            copyrightLabel.text = "© \(copyright)"
            addCopyrightLabel()
        }
        
        switch apod.mediaType {
        case .video:
            setupViewForVideo()
        case .image:
            break
        }
        
        layoutIfNeeded()
    }
    
    func addCopyrightLabel() {
        addSubview(copyrightLabel)
        copyrightLabel.font = UIFont.systemFont(ofSize: 8)
        copyrightLabel.textAlignment = .right
        
        explanationScrollView.snp.remakeConstraints { (view) in
            view.leading.trailing.equalTo(titleLabel)
            view.top.equalTo(titleLabel.snp.bottom).offset(margin)
        }
        
        copyrightLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(titleLabel)
            view.top.equalTo(explanationScrollView.snp.bottom).offset(margin)
            view.bottom.equalToSuperview().offset(-margin)
        }
    }
    
    func setupViewForVideo() {
        addSubview(videoPlayView)
        videoPlayView.playButton.addTarget(self, action: #selector(videoButtonTapped), for: .touchUpInside)
        
        titleLabel.snp.remakeConstraints { (view) in
            view.leading.equalToSuperview().offset(margin)
            view.trailing.equalToSuperview().offset(-margin)
            view.top.equalTo(videoPlayView.snp.bottom).offset(margin)
        }
        videoPlayView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            let width = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
            view.width.height.equalTo(width * 0.2)
            view.top.equalToSuperview().offset(margin)
        }
    }
    
    
    
    @objc func videoButtonTapped() {
        delegate.videoButtonTapped()
    }
}
