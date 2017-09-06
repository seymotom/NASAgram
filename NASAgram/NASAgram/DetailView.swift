//
//  DetailView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit


class DetailView: UIView {
    
//    var delegate: DetailViewDelegate!
    
    let margin: CGFloat = 11.0

    var titleLabel = DetailLabel()
    var explanationScrollView = ExplanationScrollView()
//    var videoLabel = DetailLabel()
    var copyrightLabel = DetailLabel()
    
    let backgroundView = BlurredBackgroundView(style: .dark)
        
//    convenience init(delegate: DetailViewDelegate) {
//        self.init(frame: CGRect.zero)
//        self.delegate = delegate
//        setup()
//    }

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
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
        
//        videoLabel.text = "This is a video, open in browser?"
//        videoLabel.isUserInteractionEnabled = true
//        addSubview(videoLabel)
//        
//        let videoTap = UITapGestureRecognizer()
//        videoTap.delegate = delegate as? UIGestureRecognizerDelegate
//        videoTap.numberOfTapsRequired = 1
//        videoTap.addTarget(delegate , action: #selector (delegate.videoLabelTapped))
//        videoLabel.addGestureRecognizer(videoTap)
        
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
//        videoLabel.snp.makeConstraints { (view) in
//            view.leading.trailing.equalTo(titleLabel)
//            view.top.equalTo(explanationScrollView.snp.bottom).offset(margin)
//            view.bottom.equalToSuperview().offset(-margin)
//        }
    }
    
    func populateInfo(from apod: APOD) {
//        videoLabel.isHidden = apod.mediaType == .image ? true : false
        titleLabel.text = apod.title
        explanationScrollView.explanationLabel.text = apod.explanation
        
        if let copyright = apod.copyright {
            copyrightLabel.text = "© \(copyright)"
            addCopyrightLabel()
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
}
