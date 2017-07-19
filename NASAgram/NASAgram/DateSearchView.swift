//
//  DateSearchView.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class DateSearchView: UIView {

    var delegate: APODInfoView!
    
    let margin = 20.0
    
    var datePicker = UIDatePicker()
    var doneButton = UIButton()
    
    var backgroundView: UIVisualEffectView!
    
    convenience init(delegate: APODInfoView) {
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
        
        backgroundColor = .clear
        let effect = UIBlurEffect(style: .regular)
        backgroundView = UIVisualEffectView(effect: effect)
        addSubview(backgroundView)
        
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        addSubview(datePicker)
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(delegate, action: #selector (delegate.datePickerDidChange), for: .touchUpInside)
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


}
