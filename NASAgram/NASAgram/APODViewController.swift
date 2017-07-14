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
    func toggleFavorite()
    func toggleTabBar()
    func openVideoURL()
//    func handleGesture(sender: UITapGestureRecognizer)
}

class APODViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let date: Date!
    
    let manager: APODManager!
    
    var apod: APOD? {
        return manager.data.apod(for: date.yyyyMMdd())
    }
    
    let apodImageView = APODImageView()
    let apodInfoView = APODInfoView()
    
    var alertFactory: AlertFactory!
    
    init(date: Date, dateDelegate: APODDateDelegate, manager: APODManager) {
        self.date = date
        self.apodInfoView.dateDelegate = dateDelegate
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alertFactory = AlertFactory(for: self)
        setupView()
        setupConstraints()
        setupGestures()
        getAPOD()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toggleTabBar()
        
        // reset the favorites star if deleted from favorites
        if let apod = apod {
            apodInfoView.populateInfo(from: apod)
        }
    }
    
    
    func setupView() {
        view.backgroundColor = .black
        view.addSubview(apodImageView)
        
        view.addSubview(apodInfoView)
        apodInfoView.isHidden = true
        apodInfoView.viewDelegate = self
    }
    
    func setupConstraints() {
        apodImageView.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.top.equalToSuperview()
        }
        
        apodInfoView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(topLayoutGuide.snp.bottom)
            view.bottom.equalTo(bottomLayoutGuide.snp.top)
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
    
    func getAPOD() {
        // checks favorites before hitting api
        if let apod = manager.favorites.fetchAPOD(date: date.yyyyMMdd()) {
            DispatchQueue.main.async {
                self.apodInfoView.populateInfo(from: apod)
                if apod.mediaType == .image {
                    self.apodImageView.image = UIImage(data: apod.hdImageData! as Data)
                }
            }
        } else {
            self.loadAPOD()
        }
    }
    
    func loadAPOD() {
        manager.data.getAPOD(from: date) { (apod, errorMessage) in
            guard let apod = apod else {
                self.alertFactory.showErrorAlert(message: errorMessage!)
                return
            }
            DispatchQueue.main.async {
                self.apodInfoView.populateInfo(from: apod)
            }
            
            if apod.mediaType == .image {
                if let hdurl = apod.hdurl {
                    self.manager.data.getImage(url: hdurl) { (data, errorMessage) in
                        guard let data = data else {
                            self.alertFactory.showErrorAlert(message: errorMessage!)
                            return
                        }
                        self.apod?.hdImageData = data as NSData
                        let image = UIImage(data: data)
                        self.apod?.ldImageData = UIImageJPEGRepresentation(image!, 0.25)! as NSData
                        DispatchQueue.main.async {
                            self.apodImageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    func handleGesture(sender: UITapGestureRecognizer) {
        if apodInfoView.isHidden {
            switch sender.numberOfTapsRequired {
            case 1:
//                apodInfoView.isHidden = apodInfoView.isHidden ? false : true
                apodInfoView.isHidden = false
                toggleTabBar()
            case 2 where apodInfoView.isHidden && apod?.mediaType == .image:
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

extension APODViewController: APODViewDelegate {
    
    func toggleTabBar() {
        tabBarController?.tabBar.isHidden = apodInfoView.isHidden ? true : false
    }
    
    func toggleFavorite() {
        
        guard let apod = apod else { return }
        
        if apod.isFavorite {
            manager.favorites.delete(apod)
        } else {
            manager.favorites.save(apod)
        }
        DispatchQueue.main.async {
            self.apodInfoView.populateInfo(from: apod)
        }
    }
    
    func openVideoURL() {
        guard let apod = apod, let url = URL(string: apod.url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}



