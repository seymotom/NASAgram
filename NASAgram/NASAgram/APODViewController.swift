
//  APODViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit


class APODViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let date: Date!
    
    let manager: APODManager!
    
    var apod: APOD? {
        return manager?.data.apod(for: date.yyyyMMdd())
    }
    
    var errorMessage: String?
    
    var indexPath: IndexPath?
    
    var dateView: DateView!
    var apodImageView:APODImageView!
    var apodDetailView: DetailView!
    
    var alertFactory: AlertFactory!
    var pageViewDelegate: APODPageViewDelegate!
    
    let videoPlayView = VideoPlayView()
    
    var isViewAppeared: Bool = false
    var isHidingDetail: Bool = true
    var noImageToDisplay: Bool = false
    
    init(date: Date, pageViewDelegate: APODPageViewDelegate?, manager: APODManager) {
        self.date = date
        self.manager = manager
        self.pageViewDelegate = pageViewDelegate

        dateView = DateView(date: date)
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
        checkFavoritesForAPOD()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pageViewDelegate.showToolTabStatusBars(!isHidingDetail)
        setupDateView()
        
        DispatchQueue.main.async {
            self.constrainDateView()
            self.apodImageView.resetForOrientation()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppeared = true
        
        if let apod = self.apod {
            self.pageViewDelegate.toolBarView.setFavorite(apod.isFavorite)
        }
        
        if let error = errorMessage {
            alertFactory.showErrorAlert(message: error)
            errorMessage = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewAppeared = false
    }
    
    func setupView() {
        view.backgroundColor = .black
        apodImageView = APODImageView()
        view.addSubview(apodImageView)
        apodDetailView = DetailView(delegate: self)
        view.addSubview(apodDetailView)
        view.addSubview(dateView)
        apodDetailView.isHidden = isHidingDetail
        
    }
    
    func setupConstraints() {
        
        apodImageView.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.top.equalToSuperview()
        }
        
        constrainDetailView(for: .image)
        
        constrainDateView()
    }
    
    func constrainDateView() {
        // UIDevice.current.orientation.isLandscape doesn't detect isLandscape on first load so comparing the screen height and width to tell if landscape
        let offset = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? ToolBarView.height : pageViewDelegate.statusBarHeightWhenNotHidden + ToolBarView.height
        
        dateView.snp.remakeConstraints { (view) in
            view.top.equalToSuperview().offset(offset + dateView.margin)
            view.width.equalToSuperview().multipliedBy(DateView.widthMultiplier)
            view.height.equalTo(DateView.height)
            view.centerX.equalToSuperview()
        }
    }
    
    func constrainDetailView(for mediaType: MediaType) {
        
        apodDetailView.snp.remakeConstraints { (view) in
            view.width.centerX.equalTo(dateView)
            view.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-apodDetailView.margin)
            
            switch mediaType {
            case .image:
                view.top.equalTo(self.view.snp.centerY)
            case .video:
                view.top.equalTo(self.dateView.snp.bottom).offset(apodDetailView.margin)
            }
        }
    }
    
    func resetForRotation() {
        apodImageView.resetForOrientation()
        constrainDateView()
    }
    
    func setupGestures() {
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        tapRecognizer.addTarget(self, action: #selector(handleGesture(sender:)))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)

        let doubleTapRecognizer = UITapGestureRecognizer()
        doubleTapRecognizer.numberOfTapsRequired = 2
        tapRecognizer.require(toFail: doubleTapRecognizer)
        doubleTapRecognizer.delegate = self
        doubleTapRecognizer.addTarget(self, action: #selector(handleGesture(sender:)))
        doubleTapRecognizer.cancelsTouchesInView = false
        apodImageView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    func configureViewForNoImage(errorMessage: String? = nil) {
        noImageToDisplay = true
        if isViewAppeared {
            pageViewDelegate.showToolTabStatusBars(true)
            if let error = errorMessage {
                alertFactory.showErrorAlert(message: error)
            }
        } else {
            self.errorMessage = errorMessage
        }
        
        apodImageView.stopActivityIndicator()
        
        isHidingDetail = false
        fadeView(dateView, hide: false)
        if let _ = apod {
            fadeView(apodDetailView, hide: false)
        }
    }
    
    func configureViewForAPOD(_ apod: APOD) {
        if isViewAppeared {
            pageViewDelegate.toolBarView.setFavorite(apod.isFavorite)
        }
        apodDetailView.populateInfo(from: apod)
        constrainDetailView(for: apod.mediaType)
    }
    
    
    func setupDateView() {
        if isHidingDetail {
            fadeView(dateView, hide: false)
        }
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dateTimerIsUp), userInfo: nil, repeats: false)
    }
    
    @objc func dateTimerIsUp() {
        if isHidingDetail {
            fadeView(dateView, hide: true)
        }
    }
    
    func checkFavoritesForAPOD() {
        // checks favorites before hitting api
        if let apod = manager?.favorites.fetchAPOD(date: date.yyyyMMdd()) {
            // needs to be on main thread for off screen VCs
            DispatchQueue.main.async {
                self.configureViewForAPOD(apod)
                if let imageData = apod.hdImageData {
                    self.apodImageView.image = UIImage(data: imageData as Data)
                } else {
                    self.configureViewForNoImage()
                }
            }
            
        } else {
            loadAPODFromAPI()
        }
    }
    
    func loadAPODFromAPI() {
        
        manager?.data.getAPOD(from: date) { (apod, errorMessage) in
            guard let apod = apod else {
                // big apod error
                DispatchQueue.main.async {
                    self.configureViewForNoImage(errorMessage: errorMessage)
                }
                return
            }
            DispatchQueue.main.async {
                self.configureViewForAPOD(apod)
            }
            
            if let hdurl = apod.hdurl {
                self.manager?.data.getImage(url: hdurl) { (data, errorMessage) in
                    guard let data = data else {
                        // no image error
                        DispatchQueue.main.async {
                            self.configureViewForNoImage(errorMessage: errorMessage)
                        }
                        return
                    }
                    self.apod?.hdImageData = data
                    let image = UIImage(data: data)
                    self.apod?.ldImageData = UIImageJPEGRepresentation(image!, 0.25)! 
                    DispatchQueue.main.async {
                        self.apodImageView.image = image
                    }
                }
            } else {
                // no image error
                DispatchQueue.main.async {
                    self.configureViewForNoImage(errorMessage: errorMessage)
                }
            }
        }
    }
    
    
    @objc func handleGesture(sender: UITapGestureRecognizer) {
        // only hide/show view if apod has loaded and has an image
        if !noImageToDisplay {
            switch sender.numberOfTapsRequired {
            case 1:
                isHidingDetail = !isHidingDetail
                pageViewDelegate.showToolTabStatusBars(!isHidingDetail)
                fadeView(dateView, hide: isHidingDetail)
                if let _ = apod {
                    fadeView(apodDetailView, hide: isHidingDetail)
                }
            case 2:
                apodImageView.doubleTapZoom(for: sender)
            default:
                break
            }
        }
    }
    
    func fadeView(_ view: UIView, hide: Bool) {
        
        let alpha: CGFloat = hide ? 0 : 1
        
        if !hide {
            view.isHidden = false
            view.alpha = 0
        }
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = alpha
        }) { (_) in
            view.isHidden = hide ? true : false
        }
    }
    
    
}

extension APODViewController: DetailViewDelegate {
    func videoButtonTapped() {
        guard let apod = apod, let url = URL(string: apod.url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}



