//
//  APODInfoView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/2/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class APODInfoView: UIView, UIGestureRecognizerDelegate {
    
    var apod: APOD? {
        didSet {
            populateInfo()
        }
    }
    
    var delegate: APODViewDelegate!
    
    var dateLabel = DetailLabel()
    var titleLabel = DetailLabel()
    var explanationLabel = DetailLabel()
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
        addSubview(titleLabel)
        explanationLabel.numberOfLines = 0
        explanationLabel.font = UIFont.systemFont(ofSize: 10)
        addSubview(explanationLabel)
        
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector (datePickerDidChange(sender:)), for: .valueChanged)
        addSubview(datePicker)
        
        favoriteButton.setTitle("⭐️", for: .normal)
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
    }
    
    private func populateInfo() {
        if let apod = apod {
            dateLabel.text = apod.date.displayString()
            datePicker.date = apod.date
            titleLabel.text = apod.title
            explanationLabel.text = apod.explanation
            layoutIfNeeded()
        }
    }
    
    func handleGesture(sender: UITapGestureRecognizer) {
        self.isHidden = true
    }
    
    func datePickerDidChange(sender: UIDatePicker) {
        delegate.dateSelected(date: sender.date)
        self.isHidden = true
    }
    
    func favoriteButtonTapped(sender: UIButton) {
        delegate.favoriteButtonTapped()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // cancel gesture if tap is in the button or datePicker
        if touch.view == favoriteButton || touch.view == datePicker {
            return false
        }
        return true
    }
    
    
}
