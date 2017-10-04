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

    private let explanationLabel = DetailLabel()
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
        explanationLabel.text = StyleManager.Text.videoPlayExplanation
        explanationLabel.font = StyleManager.Font.system(size: .small)
        explanationLabel.textAlignment = .center
        
        addSubview(playButton)
        playButton.setImage(StyleManager.Icon.playVideo, for: .normal)
    }
    
    private func setupConstraints() {
        playButton.snp.makeConstraints { (view) in
            view.leading.trailing.top.equalToSuperview()
            view.bottom.equalTo(explanationLabel.snp.top)
        }
        explanationLabel.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview()
            view.leading.equalTo(playButton.snp.centerX).offset(StyleManager.Dimension.standardMargin)
        }
    }
}
