//
//  DateSearchView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol DateSearchViewDelegate {
    func dateSelected(date: Date)
}

class DateSearchView: UIView {

    var delegate: DateSearchViewDelegate!
    
    var datePicker = UIDatePicker()
    var doneButton = UIButton()
    
    let backgroundView = BlurredBackgroundView(style: .regular)
    
    convenience init(delegate: DateSearchViewDelegate) {
        self.init(frame: CGRect.zero)
        self.delegate = delegate
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
    
    func setupViews() {
        addSubview(backgroundView)
        
        datePicker.maximumDate = Date()
        datePicker.minimumDate = DataManager.firstAPODDate
        datePicker.datePickerMode = .date
        addSubview(datePicker)
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector (datePickerDidChange), for: .touchUpInside)
        addSubview(doneButton)
    }
    
    func setupConstraints() {
        backgroundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints { (view) in
            view.leading.top.trailing.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(datePicker.snp.bottom)
            view.bottom.equalToSuperview()
        }
    }
    
    @objc func datePickerDidChange() {
        delegate.dateSelected(date: datePicker.date)
    }
}
