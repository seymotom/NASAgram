//
//  APODInfoView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/2/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class APODInfoView: UIView {
    
    var apod: APOD? {
        didSet {
            populateInfo()
        }
    }
    
    var delegate: APODViewDelegate!
    
    var dateLabel = DetailLabel()
    var titleLabel = DetailLabel()
    var explanationLabel = DetailLabel()
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
    
    func datePickerDidChange(sender: UIDatePicker) {
        delegate.dateSelected(date: sender.date)
        self.isHidden = true
    }
}
