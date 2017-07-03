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
    
    private var activityIndicator = UIActivityIndicatorView()
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            setZoom()
            activityIndicator.stopAnimating()
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
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        delegate = self
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
        }
    }
    
    private func setZoom() {
        guard let imageSize = image?.size else { return }
        let xRatio = superview!.frame.width / imageSize.width
        let yRatio = superview!.frame.size.height / imageSize.height
        let scale = min(xRatio, yRatio)
        minimumZoomScale = scale
        zoomScale = scale
        layoutIfNeeded()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateImageConstraints()
    }
    
    func updateImageConstraints() {
        let size = superview!.bounds.size
        let imageViewHeight = image!.size.height * zoomScale
        let imageViewWidth = image!.size.width * zoomScale
        let yOffset = max(0, (size.height - imageViewHeight) / 2)
        
        let xOffset = max(0, (size.width - imageViewWidth) / 2)
        
        imageView.snp.remakeConstraints { (view) in
            view.leading.equalToSuperview().offset(xOffset)
            view.trailing.equalToSuperview().offset(-xOffset)
            view.top.equalToSuperview().offset(yOffset)
            view.bottom.equalToSuperview().offset(-yOffset)
        }
        layoutIfNeeded()
    }
    
    func doubleTapZoom(for doubleTap: UITapGestureRecognizer) {
        if zoomScale == minimumZoomScale {
            // zoom in
            let point = doubleTap.location(in: imageView)
            //subtract half the size of the scrollView to center the offset
            let x = point.x - (bounds.size.width/2.0)
            let y = point.y - (bounds.size.height/2.0)
            
            // width and height of the zoomed frame
            let width = imageView.frame.width
            let height = imageView.frame.height
            
            let rect = CGRect(x: x, y: y, width: width, height: height)
            zoom(to: rect, animated: true)
        } else {
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
        }
    }


}
