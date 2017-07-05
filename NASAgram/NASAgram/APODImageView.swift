//
//  APODImageView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/2/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

class APODImageView: UIScrollView {
    
    fileprivate var imageView = UIImageView()
    
    private var activityIndicator = UIActivityIndicatorView()
    
    private var currentZoomPoint: CGPoint?
    
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
        
        // check for a zoomPoint in case zoomed in when rotating
        if let zoomPoint = currentZoomPoint {
            let zoomRect = getRect(for: zoomPoint)
            zoom(to: zoomRect, animated: false)
        }
        
        layoutIfNeeded()
    }
    
    
    // adds offset to the imageView to center image
    fileprivate func updateImageConstraints() {
        guard let screenSize = superview?.bounds.size,
            let imageSize = image?.size else { return }
            
        let imageViewHeight = imageSize.height * zoomScale
        let imageViewWidth = imageSize.width * zoomScale
        let yOffset = max(0, (screenSize.height - imageViewHeight) / 2)
        let xOffset = max(0, (screenSize.width - imageViewWidth) / 2)
        
        imageView.snp.remakeConstraints { (view) in
            view.leading.equalToSuperview().offset(xOffset)
            view.trailing.equalToSuperview().offset(-xOffset)
            view.top.equalToSuperview().offset(yOffset)
            view.bottom.equalToSuperview().offset(-yOffset)
        }
        layoutIfNeeded()
    }
    
    func rotate() {
        setZoom()
        updateImageConstraints()
    }
    
    func doubleTapZoom(for doubleTap: UITapGestureRecognizer) {
        if zoomScale == minimumZoomScale {
            // zoom in
            // Save the point to zoom in on in case of rotation
            currentZoomPoint = doubleTap.location(in: imageView)
            let zoomRect = getRect(for: currentZoomPoint!)
            zoom(to: zoomRect, animated: true)
        } else {
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
            currentZoomPoint = nil
        }
    }
    
    private func getRect(for point: CGPoint) -> CGRect {
        //subtract half the size of the scrollView to center the offset
        let x = point.x - (bounds.size.width / 2)
        let y = point.y - (bounds.size.height / 2)
        
        // width and height of the zoomed frame
        let width = imageView.frame.width
        let height = imageView.frame.height
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension APODImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateImageConstraints()
    }
}
