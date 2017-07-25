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
    var dateDelegate: APODDateDelegate?
    
    var mediaType: MediaType!
    
    var detailView: DetailView!
    var toolBarView: ToolBarView!
    var dateSearchView: DateSearchView!
    
    
    convenience init(vcType: APODVCType) {
        self.init(frame: CGRect.zero)
        toolBarView = ToolBarView(delegate: self, vcType: vcType)
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

        detailView = DetailView(delegate: self)
        detailView.alpha = 0.0
        addSubview(detailView)
        
        dateSearchView = DateSearchView(delegate: self)
        addSubview(dateSearchView)
        dateSearchView.isHidden = true
        
        addSubview(toolBarView)
        
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
        
        toolBarView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalToSuperview().offset(-50)
        }
        
        dateSearchView.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(detailView)
            view.top.equalTo(toolBarView.snp.bottom)
        }
    }
    
    func populateInfo(from apod: APOD) {
        mediaType = apod.mediaType
        if mediaType == .video  {
            hideInfo(false)
        }
        detailView.videoLabel.isHidden = mediaType == .image ? true : false
        detailView.dateLabel.text = apod.date.displayString()
        detailView.titleLabel.text = apod.title
        detailView.explanationLabel.text = apod.explanation
        
        dateSearchView.datePicker.date = apod.date
        let fav = apod.isFavorite ? "⭐️" : "☆"
        toolBarView.favoriteButton.setTitle(fav, for: .normal)
        layoutIfNeeded()
    }
    
    func hideInfo(_ hide: Bool) {
        
//        isHidden = show ? false : true
        
        if hide {
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
                self.toolBarView.snp.remakeConstraints({ (view) in
                    view.leading.trailing.equalToSuperview()
                    view.top.equalToSuperview().offset(-50)
                })
                self.detailView.alpha = 0
                self.layoutIfNeeded()
            })
            animator.addCompletion({ (_) in
                self.isHidden = true
                self.viewDelegate.toggleTabBar()
            })
            animator.startAnimation()
        } else {
            isHidden = false
            let animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear) {
                self.toolBarView.snp.remakeConstraints({ (view) in
                    view.leading.trailing.top.equalToSuperview()
                })
                
                self.detailView.alpha = 1.0
                self.layoutIfNeeded()
            }
            animator.startAnimation()
        }
        
        
        
    }
    
    func handleGesture(sender: UITapGestureRecognizer) {
        let show = mediaType == .image ? true : false
        hideInfo(true)
        viewDelegate.toggleTabBar()
    }
    
    func datePickerDidChange() {
        dateDelegate?.dateSelected(date: dateSearchView.datePicker.date)
        let show = mediaType == .image ? true : false
        hideInfo(show)
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
        if touch.view == toolBarView || touch.view?.superview == toolBarView { // || touch.view == datePicker {
            return false
        }
        return true
    }
    
    
}
