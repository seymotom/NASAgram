//
//  VideoPlayView.swift
//  NASAgram
//
//  Created by Tom Seymour on 9/5/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

class VideoPlayView: UIView {

    let explanationLabel = DetailLabel()
    let playButton = UIButton()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    private func setup() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        addSubview(explanationLabel)
        explanationLabel.text = "open video in browser?"
        explanationLabel.font = UIFont.systemFont(ofSize: 8)
        explanationLabel.textAlignment = .center
        
        addSubview(playButton)
        playButton.setImage(#imageLiteral(resourceName: "video-play-3-xxl"), for: .normal)
    }
    
    private func setupConstraints() {
        playButton.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        explanationLabel.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview()
            view.leading.equalTo(playButton.snp.trailing)
        }
    }
}
