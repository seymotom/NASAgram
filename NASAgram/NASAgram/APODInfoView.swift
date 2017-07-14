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
    var dateDelegate: APODDateDelegate!
    
    var mediaType: MediaType!
    
    var dateLabel = DetailLabel()
    var titleLabel = DetailLabel()
    var explanationLabel = DetailLabel()
    var videoLabel = DetailLabel()
    
    var favoriteButton = UIButton()
    
    var backgroundView: UIVisualEffectView!
    
    let datePicker = UIDatePicker()
    
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
        backgroundColor = .clear
        let effect = UIBlurEffect(style: .dark)
        backgroundView = UIVisualEffectView(effect: effect)
        addSubview(backgroundView)
        addSubview(dateLabel)
        dateLabel.textAlignment = .center
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        
        let videoTap = UITapGestureRecognizer()
        videoTap.delegate = self
        videoTap.numberOfTapsRequired = 1
        videoTap.addTarget(self, action: #selector (videoLabelTapped))
        videoLabel.addGestureRecognizer(videoTap)
        videoLabel.text = "This is a video, open in browser?"
        videoLabel.isUserInteractionEnabled = true
        addSubview(videoLabel)
        
        explanationLabel.numberOfLines = 0
        explanationLabel.font = UIFont.systemFont(ofSize: 10)
        addSubview(explanationLabel)
        
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector (datePickerDidChange(sender:)), for: .valueChanged)
        datePicker.backgroundColor = .white
        addSubview(datePicker)
        
        favoriteButton.addTarget(self, action: #selector (favoriteButtonTapped(sender:)), for: .touchUpInside)
        addSubview(favoriteButton)
        
        
        // have to put a tap gesture on this view to dismiss the info
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 1
        recognizer.delegate = self
        recognizer.addTarget(self, action: #selector(handleGesture(sender:)))
        recognizer.cancelsTouchesInView = false
        addGestureRecognizer(recognizer)
        
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(50)
            view.leading.trailing.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(dateLabel.snp.bottom)
        }
        explanationLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(titleLabel.snp.bottom)
        }
        datePicker.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(explanationLabel.snp.bottom).offset(20)
        }
        favoriteButton.snp.makeConstraints { (view) in
            view.leading.top.equalToSuperview().offset(10)
        }
        videoLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(datePicker.snp.bottom)
        }
    }
    
    func populateInfo(from apod: APOD) {
        mediaType = apod.mediaType
        if mediaType == .video  {
            isHidden = false
        }
        videoLabel.isHidden = mediaType == .image ? true : false
        
        dateLabel.text = apod.date.displayString()
        datePicker.date = apod.date
        titleLabel.text = apod.title
        explanationLabel.text = apod.explanation
        let fav = apod.isFavorite ? "⭐️" : "☆"
        favoriteButton.setTitle(fav, for: .normal)
        layoutIfNeeded()
    }
    
    func handleGesture(sender: UITapGestureRecognizer) {
        isHidden = mediaType == .image ? true : false
        viewDelegate.toggleTabBar()
    }
    
    func datePickerDidChange(sender: UIDatePicker) {
        dateDelegate.dateSelected(date: sender.date)
        isHidden = mediaType == .image ? true : false
    }
    
    func favoriteButtonTapped(sender: UIButton) {
        viewDelegate.toggleFavorite()
    }
    
    func videoLabelTapped() {
        viewDelegate.openVideoURL()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // cancel gesture if tap is in the button or datePicker
        if touch.view == favoriteButton || touch.view == datePicker {
            return false
        }
        return true
    }
    
    
}
