//
//  APODInfoView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/2/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class APODInfoView: UIView, UIGestureRecognizerDelegate {
    
    var viewDelegate: APODViewDelegate!
    var pageViewDelegate: APODPageViewDelegate!
    
    var mediaType: MediaType?
    
    var detailView: DetailView!
    var dateSearchView: DateSearchView!
    
    convenience init(vcType: APODVCType) {
        self.init(frame: CGRect.zero)
//        toolBarView = ToolBarView(delegate: self, vcType: vcType)
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
    
    private func setupViews() {
        backgroundColor = .clear

//        detailView = DetailView(delegate: self)
        detailView.alpha = 0.0
        addSubview(detailView)
        
        dateSearchView = DateSearchView(delegate: self)
        addSubview(dateSearchView)
        dateSearchView.isHidden = true
        
        // have to put a tap gesture on this view to dismiss the info
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 1
        recognizer.delegate = self
        recognizer.addTarget(self, action: #selector(handleGesture(sender:)))
        recognizer.cancelsTouchesInView = false
        addGestureRecognizer(recognizer)
        
    }
    
    private func setupConstraints() {
        
        detailView.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.8)
        }
        
        dateSearchView.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(detailView)
            view.top.equalToSuperview()
        }
    }
        
    func populateInfo(from apod: APOD) {
        mediaType = apod.mediaType
        detailView.videoLabel.isHidden = mediaType == .image ? true : false
        detailView.titleLabel.text = apod.title
        detailView.explanationLabel.text = apod.explanation
        dateSearchView.datePicker.date = apod.date
//        let fav = apod.isFavorite ? "⭐️" : "☆"
//        toolBarView.favoriteButton.setTitle(fav, for: .normal)
        layoutIfNeeded()
    }
    
    var isBeingHidden = true
    
    func hideInfo(_ hide: Bool, animated: Bool) {
        
        if animated {
            
            DispatchQueue.main.async {
                
                if hide {
                    self.isBeingHidden = true
                    self.viewDelegate.setTabBarVisible(visible: false, animated: true, completion: {_ in })
                    self.viewDelegate.setNavbarVisible(visible: false, animated: true, completion: {_ in })
                    self.viewDelegate.toggleStatusBar()
                    
                    
                    let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut, animations: {
                        self.detailView.alpha = 0
                        self.layoutIfNeeded()
                    })
                    animator.addCompletion({ (_) in
                        self.isHidden = true
                    })
                    animator.startAnimation()
                } else {
                    self.isHidden = false
                    self.isBeingHidden = false
                    self.viewDelegate.toggleStatusBar()
                    self.viewDelegate.setTabBarVisible(visible: true, animated: true, completion: {_ in })
                    self.viewDelegate.setNavbarVisible(visible: true, animated: true, completion: {_ in })
                    let animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
                        self.detailView.alpha = 1.0
                        self.layoutIfNeeded()
                    }
                    animator.startAnimation()
                }
            }
        } else {
            isHidden = !hide ? false : true
            isBeingHidden = isHidden
            viewDelegate.toggleStatusBar()
        }
        
    }
    
    func handleGesture(sender: UITapGestureRecognizer) {
        if mediaType == .image {
            hideInfo(true, animated: true)
            viewDelegate.hideDateView(true)
        }
    }
    
    func datePickerDidChange() {
        pageViewDelegate?.dateSelected(date: dateSearchView.datePicker.date)
        let show = mediaType == .image ? true : false
        hideInfo(show, animated: true)
    }
    
    func favoriteButtonTapped(sender: UIButton) {
        viewDelegate.toggleFavorite()
    }
    
    func optionsButtonTapped(sender: UIButton) {
        print("hamburger")
    }
    
    func dateSearchButtonTapped(sender: UIButton) {
        dateSearchView.isHidden = dateSearchView.isHidden ? false : true
    }
    
    func dismissButtonTapped(sender: UIButton) {
        viewDelegate.dismissVC()
    }
    
    func videoLabelTapped() {
        viewDelegate.openVideoURL()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // cancel gesture if tap is in the button or datePicker
//        if touch.view == toolBarView || touch.view?.superview == toolBarView { // || touch.view == datePicker {
//            return false
//        }
        
        return true
    }
    
    
}
