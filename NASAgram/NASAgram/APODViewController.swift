
//  APODViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit


@objc protocol DetailViewDelegate {
    func videoLabelTapped()
}

class APODViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let date: Date!
    
    let manager: APODManager!
    
    var apod: APOD? {
        return manager?.data.apod(for: date.yyyyMMdd())
    }
    
    var indexPath: IndexPath?
    
    var dateView: DateView!
    var apodImageView:APODImageView!
    var apodDetailView: DetailView!
    
    var alertFactory: AlertFactory!
    var pageViewDelegate: APODPageViewDelegate!
    
    var isViewAppeared: Bool = false
    
    var isHidingDetail: Bool = true
    
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
        getAPOD()
        self.edgesForExtendedLayout = .top
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewAppeared = true
        
        pageViewDelegate.showToolTabStatusBars(!isHidingDetail)
        setupDateView()
        
        DispatchQueue.main.async {
            self.apodImageView.resetForOrientation()
            if let apod = self.apod {
                self.pageViewDelegate.toolBarView.setFavorite(apod.isFavorite)
            }
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
        apodDetailView.snp.makeConstraints { (view) in
            view.width.centerX.equalTo(dateView)
            view.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-apodDetailView.margin)
            view.top.equalTo(self.view.snp.centerY)
        }
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
    
    func configureViewForVideo() {
        apodImageView.stopActivityIndicator()
        isHidingDetail = false
        apodDetailView.isHidden = false
        dateView.isHidden = false
    }
    
    func setupDateView() {
        if isHidingDetail {
            fadeView(dateView, hide: false)
        }
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(dateTimerIsUp), userInfo: nil, repeats: false)
    }
    
    func dateTimerIsUp() {
        if isHidingDetail {
            fadeView(dateView, hide: true)
        }
    }
    
    func getAPOD() {
        // checks favorites before hitting api
        if let apod = manager?.favorites.fetchAPOD(date: date.yyyyMMdd()) {
            DispatchQueue.main.async {
                self.pageViewDelegate.toolBarView.setFavorite(apod.isFavorite)
                self.apodDetailView.populateInfo(from: apod)
                switch apod.mediaType {
                case .image:
                    self.apodImageView.image = UIImage(data: apod.hdImageData! as Data)
                case .video:
                    self.configureViewForVideo()
                }
            }
        } else {
            loadAPOD()
        }
    }
    
    func loadAPOD() {
        
        manager?.data.getAPOD(from: date) { (apod, errorMessage) in
            guard let apod = apod else {
                self.alertFactory.showErrorAlert(message: errorMessage!)
                return
            }
            DispatchQueue.main.async {
                self.pageViewDelegate.toolBarView.setFavorite(apod.isFavorite)
                self.apodDetailView.populateInfo(from: apod)
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
                self.configureViewForVideo()
            }
        }
    }
    
    
    func handleGesture(sender: UITapGestureRecognizer) {
        switch sender.numberOfTapsRequired {
        case 1:
            // only hide/show view if apod has loaded and is an image
            if let apod = apod, apod.mediaType == .image {
                isHidingDetail = !isHidingDetail
                fadeView(dateView, hide: isHidingDetail)
                fadeView(apodDetailView, hide: isHidingDetail)
                pageViewDelegate.showToolTabStatusBars(!isHidingDetail)
            }
        case 2:
            apodImageView.doubleTapZoom(for: sender)
        default:
            break
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
    
    func videoLabelTapped() {
        guard let apod = apod, let url = URL(string: apod.url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

