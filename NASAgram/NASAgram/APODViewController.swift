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
    func favoriteButtonTapped()
}

class APODViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let date: Date!
    
    let apodImageView = APODImageView()
    let apodInfoView = APODInfoView()
    
    init(date: Date, delegate: APODViewDelegate) {
        self.date = date
        self.apodInfoView.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupGestures()
        loadAPOD()
    }
    
    func setupView() {
        view.backgroundColor = .black
        view.addSubview(apodImageView)
        view.addSubview(apodInfoView)
        apodInfoView.isHidden = true
    }
    
    func setupConstraints() {
        apodImageView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        
        apodInfoView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    func setupGestures() {
        var recognizers = [UIGestureRecognizer]()
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        recognizers.append(tapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer()
        doubleTapRecognizer.numberOfTapsRequired = 2
        tapRecognizer.require(toFail: doubleTapRecognizer)
        recognizers.append(doubleTapRecognizer)
        
        recognizers.forEach { (recognizer) in
            recognizer.delegate = self
            recognizer.addTarget(self, action: #selector(handleGesture(sender:)))
            recognizer.cancelsTouchesInView = false
            view.addGestureRecognizer(recognizer)
        }
    }
    
    func loadAPOD() {
        DataManager.shared.getAPOD(from: date) { (apod) in
            DispatchQueue.main.async {
                self.apodInfoView.apod = apod
            }
            switch apod.mediaType {
            case .image:
                if let hdurl = apod.hdurl {
                    DataManager.shared.getImage(url: hdurl, completion: { (data) in
                        DispatchQueue.main.async {
                            self.apodImageView.image = UIImage(data: data)
                        }
                    })
                }
            case .video:
                print("Video")
                self.apodImageView.image = nil
            }
        }
    }
    
    func handleGesture(sender: UITapGestureRecognizer) {
        if apodInfoView.isHidden {
            switch sender.numberOfTapsRequired {
            case 1:
                //            apodInfoView.isHidden = apodInfoView.isHidden ? false : true
                apodInfoView.isHidden = false
            case 2 where apodInfoView.isHidden:
                apodImageView.doubleTapZoom(for: sender)
            default:
                break
            }
        }
    }
    
    // MARK:- Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.apodImageView.rotate()
        }) { (context) in
        }
    }
    
    
}
