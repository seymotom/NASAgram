
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
    func toggleStatusBar()
    func hideDateView(_ hide: Bool)
    func openVideoURL()
    func dismissVC()
    func setTabBarVisible(visible: Bool, animated: Bool, completion: @escaping (Bool) -> Void)
    func setNavbarVisible(visible: Bool, animated: Bool, completion: @escaping (Bool) -> Void)
}

class APODViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let date: Date!
    
    let manager: APODManager!
    
    var apod: APOD? {
        return manager?.data.apod(for: date.yyyyMMdd())
    }
    
    var apodImageView:APODImageView!
    let apodInfoView: APODInfoView!
    var dateView: DateView!
//    let statusBarBackgorundView = BlurredBackgroundView(style: .dark)
    
    var alertFactory: AlertFactory!
    var pageViewDelegate: APODPageViewDelegate!
    
    var isViewAppeared: Bool = false
    
    init(date: Date, pageViewDelegate: APODPageViewDelegate?, manager: APODManager, vcType: APODVCType) {
        self.date = date
        self.manager = manager
        self.pageViewDelegate = pageViewDelegate
        apodInfoView = APODInfoView(vcType: vcType)
        dateView = DateView(date: date)
        self.apodInfoView.pageViewDelegate = pageViewDelegate
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
        isViewAppeared = true
        toggleStatusBar()
        
        setTabBarVisible(visible: !apodInfoView.isBeingHidden, animated: true, completion: {_ in })
        setNavbarVisible(visible: !apodInfoView.isBeingHidden, animated: true, completion:{_ in })
        
        DispatchQueue.main.async {
            self.apodImageView.resetForOrientation()
        }
        
        // reset the favorites star if deleted from favorites
        if let apod = apod {
            apodInfoView.populateInfo(from: apod)
            if apod.mediaType == .video {
                apodInfoView.hideInfo(false, animated: true)
            }
        }
        setupDateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewAppeared = false
    }
    
    
    func setupView() {
        view.backgroundColor = .black
        apodImageView = APODImageView()
        view.addSubview(apodImageView)
//        view.addSubview(statusBarBackgorundView)
        view.addSubview(dateView)
        view.addSubview(apodInfoView)
        apodInfoView.viewDelegate = self
        apodInfoView.hideInfo(true, animated: false)
    }
    
    func setupConstraints() {
        apodImageView.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.top.equalToSuperview()
        }
        
//        statusBarBackgorundView.snp.makeConstraints { (view) in
//            view.leading.trailing.top.equalToSuperview()
//            view.height.equalTo(UIApplication.shared.statusBarFrame.height)
//        }
        
        apodInfoView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        
        dateView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(70)
            view.width.equalToSuperview().multipliedBy(0.8)
            view.height.equalTo(50)
            view.centerX.equalToSuperview()
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
                    self.apodInfoView.hideInfo(false, animated: false)
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
                self.apodInfoView.hideInfo(false, animated: true)
            }
        }
    }
    
    
    func handleGesture(sender: UITapGestureRecognizer) {
        switch sender.numberOfTapsRequired {
        case 1 where apod != nil:
            apodInfoView.hideInfo(false, animated: true)
            hideDateView(false)
        case 2:
            apodImageView.doubleTapZoom(for: sender)
        default:
            break
        }
    }
    
    func setupDateView() {
        dateView.isHidden = false
        dateView.alpha = 1.0
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dateTimerIsUp), userInfo: nil, repeats: false)
    }
    
    func dateTimerIsUp() {
        if apodInfoView.isHidden {
            hideDateView(true)
        }
    }
    
    func hideDateView(_ hide: Bool) {
        
        let alpha: CGFloat = hide ? 0 : 1
        
        if !hide {
            dateView.isHidden = false
            dateView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.2, animations: { 
            self.dateView.alpha = alpha
        }) { (_) in
            if hide {
                self.dateView.isHidden = true
            }
        }
    }
    
    
    // MARK:- Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        toggleStatusBar()
        coordinator.animate(alongsideTransition: { (context) in
            if self.isViewAppeared {
                self.apodImageView.resetForOrientation()
            }
        }) { (context) in
        }
    }
    
}

extension APODViewController: APODViewDelegate {
    
    func toggleStatusBar() {
        // only toggleTabBar if this view is on screen as toggleTabBar gets called by adjacent viewControllers
        if isViewAppeared {
            pageViewDelegate.statusBarHidden = apodInfoView.isBeingHidden || UIDevice.current.orientation.isLandscape ? true : false
        }
    }
    
    // pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
    func setTabBarVisible(visible: Bool, animated: Bool, completion: @escaping (Bool) -> Void) {
        pageViewDelegate.setTabBarVisible(visible: visible, animated: animated, completion: completion)
    }
    
    func setNavbarVisible(visible: Bool, animated: Bool, completion: @escaping (Bool) -> Void) {
        pageViewDelegate.setNavbarVisible(visible: visible, animated: animated, completion: completion)
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



