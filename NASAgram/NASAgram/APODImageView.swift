//
//  APODImageView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/2/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

class APODImageView: UIScrollView, UIScrollViewDelegate {
    
    
    private var imageView = UIImageView()
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            setZoom()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        delegate = self
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    private func setZoom() {
        guard let imageSize = image?.size else { return }
        let xRatio = frame.size.width / imageSize.width
        let yRatio = frame.size.height / imageSize.height
        let scale = min(xRatio, yRatio)
        minimumZoomScale = scale
        zoomScale = scale
        layoutIfNeeded()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }


}
