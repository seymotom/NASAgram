//
//  DetailView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class DetailView: UIView {
    
    var delegate: APODInfoView!
    
    let margin = 20.0

    var dateLabel = DetailLabel()
    var titleLabel = DetailLabel()
    var explanationLabel = DetailLabel()
    var videoLabel = DetailLabel()
    
    var backgroundView: UIVisualEffectView!
    
    convenience init(delegate: APODInfoView) {
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
        
        backgroundColor = .clear
        let effect = UIBlurEffect(style: .dark)
        backgroundView = UIVisualEffectView(effect: effect)
        addSubview(backgroundView)
        addSubview(dateLabel)
        dateLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
        
        videoLabel.text = "This is a video, open in browser?"
        videoLabel.isUserInteractionEnabled = true
        addSubview(videoLabel)
        
        explanationLabel.numberOfLines = 0
        explanationLabel.font = UIFont.systemFont(ofSize: 10)
        addSubview(explanationLabel)
        
        let videoTap = UITapGestureRecognizer()
        videoTap.delegate = delegate
        videoTap.numberOfTapsRequired = 1
        videoTap.addTarget(delegate , action: #selector (delegate.videoLabelTapped))
        videoLabel.addGestureRecognizer(videoTap)
    }
    
    func setupConstraints() {
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { (view) in
            view.top.leading.equalToSuperview().offset(margin)
            view.trailing.equalToSuperview().offset(-margin)
        }
        titleLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(dateLabel)
            view.top.equalTo(dateLabel.snp.bottom)
        }
        explanationLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(dateLabel)
            view.top.equalTo(titleLabel.snp.bottom)
        }
        videoLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(dateLabel)
            view.top.equalTo(explanationLabel.snp.bottom).offset(margin)
            view.bottom.equalToSuperview().offset(-margin)
        }
    }
}
