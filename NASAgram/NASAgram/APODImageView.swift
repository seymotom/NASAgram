//
//  APODImageView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/2/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit
import DGActivityIndicatorView

class APODImageView: UIScrollView {
    
    private let fadeInAnimationDuration = 0.2
    private let activityIndicatorSize: CGFloat = 100
    
    fileprivate var imageView = UIImageView()
    
    private var activityIndicator: DGActivityIndicatorView!
    
    fileprivate var currentZoomPoint: CGPoint?
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            fadeInImageView()
            setZoom()
            activityIndicator?.stopAnimating()
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
        imageView.alpha = 0.0
        addSubview(imageView)
        
        activityIndicator = DGActivityIndicatorView(type: .ballClipRotateMultiple, tintColor: .lightGray, size: activityIndicatorSize)
        addSubview(activityIndicator!)
        activityIndicator?.startAnimating()
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        
        activityIndicator?.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
        }
    }
    
    private func fadeInImageView() {
        UIView.animate(withDuration: fadeInAnimationDuration, animations: {
            self.imageView.alpha = 1.0
        })
    }
    
    private func setZoom() {
        // capture zoomPoint before setting zoomScale because didScroll gets called and fucks with it
        let zoomPointBeforeRotation = self.currentZoomPoint
        let zoomScaleBeforeRotation = zoomScale
        
        guard let imageSize = image?.size else { return }
        let xRatio = superview!.frame.width / imageSize.width
        let yRatio = superview!.frame.size.height / imageSize.height
        let scale = min(xRatio, yRatio)
        minimumZoomScale = scale
        zoomScale = scale
        // check for a zoomPoint in case zoomed in when rotating
        if let zoomPoint = zoomPointBeforeRotation {
            let zoomRect = getRect(centerPoint: zoomPoint, zoomScale: zoomScaleBeforeRotation)
            zoom(to: zoomRect, animated: false)
        }
        layoutIfNeeded()
    }
    
    // returns the rect to zoom to
    private func getRect(centerPoint: CGPoint, zoomScale: CGFloat = 1) -> CGRect {
        //subtract half the size of the scrollView to center the offset and then divide by zoomScale
        let x = (centerPoint.x - (bounds.size.width / 2)) / zoomScale
        let y = (centerPoint.y - (bounds.size.height / 2)) / zoomScale
        
        // width and height of the zoomed frame
        let width = imageView.frame.width / zoomScale
        let height = imageView.frame.height / zoomScale
        
        return CGRect(x: x, y: y, width: width, height: height)
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
    
    // saves the center point in imageView so that it can rotate to same position
    fileprivate func updateCurrentZoomPoint(forOffset offset: CGPoint) {
        let x = offset.x + (bounds.size.width / 2)
        let y = offset.y + (bounds.size.height / 2)
        currentZoomPoint = zoomScale <= minimumZoomScale ? nil : CGPoint(x: x, y: y)
    }
    
    // MARK: - Internal Methods
    
    func resetForRotation() {
        setZoom()
        updateImageConstraints()
    }
    
    func doubleTapZoom(for doubleTap: UITapGestureRecognizer) {
        if zoomScale == minimumZoomScale {
            // zoom in
            // Save the point to zoom in on in case of rotation
            currentZoomPoint = doubleTap.location(in: imageView)
            let zoomRect = getRect(centerPoint: currentZoomPoint!)
            zoom(to: zoomRect, animated: true)
        } else {
            // zoom out
            setZoomScale(minimumZoomScale, animated: true)
            currentZoomPoint = nil
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
//    private func getRect(for point: CGPoint, thisZoomScale: CGFloat = 1) -> CGRect {
//        //subtract half the size of the scrollView to center the offset
//        print("image size: \(image!.size)")
//        print("imageView bounds: \(imageView.bounds)")
//
//        print("self.zoomScale: \(zoomScale)")
//
//        print("point: \(point)")
//        print("this zoom scale: \(thisZoomScale)")
//
//
//        let x = (point.x - (bounds.size.width / 2) ) / thisZoomScale
//        let y = (point.y - (bounds.size.height / 2) ) / thisZoomScale
//        print("x: \(x), y: \(y)")
//        print("bounds: \(bounds.size)")
//
//        
//        // width and height of the zoomed frame
//        let width = imageView.frame.width / thisZoomScale
//        let height = imageView.frame.height / thisZoomScale
//
//        print("imageView.frame: \(imageView.frame)")
//        print("scrollView.frame: \(frame)")
//
//        let rect = CGRect(x: x, y: y, width: width, height: height)
//
//        print("rect to zoom to: \(rect)")
//        print("___________________________")
//        return rect
//    }
    
}

extension APODImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateImageConstraints()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCurrentZoomPoint(forOffset: scrollView.contentOffset)
    }
}
