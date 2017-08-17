//
//  DetailView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class DetailView: UIView {
    
    var delegate: DetailViewDelegate!
    
    let margin = 20.0

    var titleLabel = DetailLabel()
    var explanationLabel = DetailLabel()
    var videoLabel = DetailLabel()
    
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
        
        addSubview(titleLabel)
        
        videoLabel.text = "This is a video, open in browser?"
        videoLabel.isUserInteractionEnabled = true
        addSubview(videoLabel)
        
        explanationLabel.numberOfLines = 0
        explanationLabel.font = UIFont.systemFont(ofSize: 10)
        addSubview(explanationLabel)
        
        let videoTap = UITapGestureRecognizer()
        videoTap.delegate = delegate as? UIGestureRecognizerDelegate
        videoTap.numberOfTapsRequired = 1
        videoTap.addTarget(delegate , action: #selector (delegate.videoLabelTapped))
        videoLabel.addGestureRecognizer(videoTap)
    }
    
    func setupConstraints() {
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (view) in
            view.top.leading.equalToSuperview().offset(margin)
            view.trailing.equalToSuperview().offset(-margin)
        }
        explanationLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(titleLabel)
            view.top.equalTo(titleLabel.snp.bottom)
        }
        videoLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(titleLabel)
            view.top.equalTo(explanationLabel.snp.bottom).offset(margin)
            view.bottom.equalToSuperview().offset(-margin)
        }
    }
    
    func populateInfo(from apod: APOD) {
        let mediaType = apod.mediaType
        videoLabel.isHidden = mediaType == .image ? true : false
        titleLabel.text = apod.title
        explanationLabel.text = apod.explanation
        layoutIfNeeded()
    }
}
