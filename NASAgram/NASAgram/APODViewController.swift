//
//  APODViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

protocol APODViewDelegate {
    func dateSelected(date: Date)
}

class APODViewController: UIViewController {
    
    let date: Date!
    
    let delegate: APODViewDelegate!
    
    let apodImageView = UIImageView()
    let dateLabel = UILabel()
    let datePicker = UIDatePicker()
    
    init(date: Date, delegate: APODViewDelegate) {
        self.date = date
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupView()
        setupConstraints()
        loadAPOD()
    }
    
    func setupView() {
        
        apodImageView.contentMode = .scaleAspectFit
        apodImageView.clipsToBounds = true
        view.addSubview(apodImageView)
        
        dateLabel.text = date.apodURI()
        view.addSubview(dateLabel)
        
        datePicker.date = date
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector (datePickerDidChange(sender:)), for: .valueChanged)
        view.addSubview(datePicker)
    }
    
    func setupConstraints() {
        apodImageView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { (view) in
            view.leading.trailing.top.equalToSuperview()
            view.height.equalTo(60)
        }
        datePicker.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func loadAPOD() {
        DataManager.shared.getAPOD(from: date) { (apod) in
            APIManager.shared.getData(endpoint: apod.hdurl, completion: { (data) in
                DispatchQueue.main.async {
                    self.apodImageView.image = UIImage(data: data)
                }
            })
        }
    }
    
    func datePickerDidChange(sender: UIDatePicker) {
        delegate.dateSelected(date: sender.date)
    }

    
}
