//
//  APODViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

class APODViewController: UIViewController {
    
    let date: Date!
    
    let apodImageView = UIImageView()
    let dateLabel = UILabel()
    
    init(date: Date) {
        self.date = date
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
        view.addSubview(apodImageView)
        
        dateLabel.text = date.apodURI()
        view.addSubview(dateLabel)
    }
    
    func setupConstraints() {
        apodImageView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { (view) in
            view.leading.trailing.top.equalToSuperview()
            view.height.equalTo(60)
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

    
}
