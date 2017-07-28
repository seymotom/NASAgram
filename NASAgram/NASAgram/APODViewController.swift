//
//  APODViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

enum APODVCType {
    case daily, favorite
}

protocol APODViewDelegate {
    func toggleFavorite()
    func toggleTabBar()
    func openVideoURL()
    func dismissVC()
}

class APODViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let date: Date!
    
    let manager: APODManager!
    
    var apod: APOD? {
        return manager?.data.apod(for: date.yyyyMMdd())
    }
    
    var apodImageView:APODImageView!
    let apodInfoView: APODInfoView!
    let statusBarBackgorundView = BlurredBackgroundView(style: .dark)
    
    var alertFactory: AlertFactory!
    
    init(date: Date, dateDelegate: APODDateDelegate?, manager: APODManager, vcType: APODVCType) {
        self.date = date
        self.manager = manager
        apodInfoView = APODInfoView(vcType: vcType)
        self.apodInfoView.dateDelegate = dateDelegate
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toggleTabBar()
        apodImageView.resetForRotation()
        
        // reset the favorites star if deleted from favorites
        if let apod = apod {
            apodInfoView.populateInfo(from: apod)
        }
    }
    
    
    func setupView() {
        view.backgroundColor = .black
        apodImageView = APODImageView()
        view.addSubview(apodImageView)
        view.addSubview(statusBarBackgorundView)
        view.addSubview(apodInfoView)
        apodInfoView.viewDelegate = self
        apodInfoView.hideInfo(true, animated: false)
    }
    
    func setupConstraints() {
        apodImageView.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.top.equalToSuperview()
        }
        
        statusBarBackgorundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.equalToSuperview()
            view.height.equalTo(UIApplication.shared.statusBarFrame.height)
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
            apodImageView.addGestureRecognizer(recognizer)
        }
    }
    
    func getAPOD() {
        // checks favorites before hitting api
        if let apod = manager?.favorites.fetchAPOD(date: date.yyyyMMdd()) {
            DispatchQueue.main.async {
                self.apodInfoView.populateInfo(from: apod)
                switch apod.mediaType {
                case .image:
                    self.apodImageView.image = UIImage(data: apod.hdImageData! as Data)
                case .video:
                    self.apodImageView.stopActivityIndicator()
                }
            }
        } else {
            self.loadAPOD()
        }
    }
    
    func loadAPOD() {
        
        manager?.data.getAPOD(from: date) { (apod, errorMessage) in
            guard let apod = apod else {
                self.alertFactory.showErrorAlert(message: errorMessage!)
                return
            }
            DispatchQueue.main.async {
                self.apodInfoView.populateInfo(from: apod)
            }
            
            switch apod.mediaType {
            case .image:
                if let hdurl = apod.hdurl {
                    self.manager?.data.getImage(url: hdurl) { (data, errorMessage) in
                        guard let data = data else {
                            self.alertFactory.showErrorAlert(message: errorMessage!)
                            self.apodImageView.stopActivityIndicator()
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
            case .video:
                self.apodImageView.stopActivityIndicator()
            }
        }
    }
    
    
    func handleGesture(sender: UITapGestureRecognizer) {
        switch sender.numberOfTapsRequired {
        case 1:
            apodInfoView.hideInfo(false, animated: true)
        case 2:
            apodImageView.doubleTapZoom(for: sender)
        default:
            break
        }
    }
    
    // Now handling rotaion from pageVC
    
    // MARK:- Rotation
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
////        toggleTabBar() // only for the pageViewControllers current view
//        coordinator.animate(alongsideTransition: { (context) in
//            self.apodImageView.resetForRotation()
//        }) { (context) in
//        }
//    }
}

extension APODViewController: APODViewDelegate {
    
    func toggleTabBar() {
        tabBarController?.tabBar.isHidden = apodInfoView.isHidden ? true : false
        UIApplication.shared.isStatusBarHidden = apodInfoView.isHidden || UIDevice.current.orientation.isLandscape ? true : false
        statusBarBackgorundView.isHidden = apodInfoView.isHidden ? true : false
        statusBarBackgorundView.snp.remakeConstraints { (view) in
            view.leading.trailing.top.equalToSuperview()
            view.height.equalTo(UIApplication.shared.statusBarFrame.height)
        }
    }
    
    func toggleFavorite() {
        
        guard let apod = apod else { return }
        
        if apod.isFavorite {
            manager?.favorites.delete(apod)
        } else {
            manager?.favorites.save(apod)
        }
        DispatchQueue.main.async {
            self.apodInfoView.populateInfo(from: apod)
        }
    }
    
    func openVideoURL() {
        guard let apod = apod, let url = URL(string: apod.url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func dismissVC() {
        self.dismiss(animated: true)
    }
}



