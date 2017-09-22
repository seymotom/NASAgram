//
//  APODPageViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 8/18/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

enum APODPageViewType {
    case daily, favorite
}

protocol APODPageViewDelegate {
    var statusBarHeightWhenNotHidden: CGFloat { get }
    var toolBarView: ToolBarView! { get }
    func showToolTabStatusBars(_ show: Bool)
}

class APODPageViewController: UIPageViewController {

    let apodManager: APODManager!
    
    var pageViewManager: APODPageViewManagerDelegate!
    
    let pageViewType: APODPageViewType
    
    let statusBarBackgorundView = BlurredBackgroundView(style: .dark)
    
    var toolBarView: ToolBarView!
    
    var dateSearchView: DateSearchView!
    
    var statusBarHidden = true {
        didSet {
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    let statusBarHeightWhenNotHidden: CGFloat
    
    var currentAPODViewController: APODViewController? {
        return viewControllers?.first as? APODViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    init(apodManager: APODManager, pageViewType: APODPageViewType, indexPath: IndexPath? = nil) {
        self.apodManager = apodManager
        self.pageViewType = pageViewType
        // statusBar height is 0 when hidden so have to capture the value here so the APODVC can use it to constrain the date
        statusBarHeightWhenNotHidden = UIApplication.shared.statusBarFrame.height
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        switch pageViewType {
        case .daily:
            pageViewManager = DailyPageViewManager(pageViewController: self, apodManager: apodManager)
        case .favorite:
            pageViewManager = FavoritesPageViewManager(pageViewController: self, apodManager: apodManager, indexPath: indexPath)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupPageVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("/n/n/n>>>>>>>>>>> !!! MEMORY WARNING !!! <<<<<<<<<<<<<\n\n\n")
        // empty the dictionary if using too much memory
        pageViewManager.seenVCs = [:]
    }
    
    func setupPageVC() {
        dataSource = pageViewManager
        delegate = pageViewManager
        pageViewManager.setupPageVC()
    }
    
    func setupView() {
        dateSearchView = DateSearchView(delegate: pageViewManager)
        view.addSubview(dateSearchView)
        dateSearchView.isHidden = true
        toolBarView = ToolBarView(delegate: self, pageViewType: pageViewType)
        view.addSubview(toolBarView)
        view.addSubview(statusBarBackgorundView)
        statusBarBackgorundView.isHidden = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? true : false
    }
    
    func setupConstraints() {
        toolBarView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(ToolBarView.height)
            view.bottom.equalTo(self.view.snp.top)
        }
        statusBarBackgorundView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(statusBarHeightWhenNotHidden)
            view.bottom.equalTo(self.view.snp.top)
        }
        dateSearchView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(self.view.snp.top)
        }
    }
    
    func setToolBarVisible(visible: Bool, animated: Bool) {
        
        // bail if the toolBarView hasn't been set yet
        if toolBarView == nil {
            return
        }
        
        self.toolBarView.snp.remakeConstraints({ (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(ToolBarView.height)
            if visible {
                view.top.equalTo(self.topLayoutGuide.snp.bottom)
            } else {
                view.bottom.equalTo(self.view.snp.top)
            }
        })
        
        self.statusBarBackgorundView.snp.remakeConstraints({ (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(statusBarHeightWhenNotHidden)
            if visible {
                view.top.equalToSuperview()
            } else {
                view.bottom.equalTo(self.view.snp.top)
            }
        })
        // zero duration means no animation
        let duration = (animated ? 0.2 : 0.0)
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    func setTabBarVisible(visible: Bool, animated: Bool) {
        // bail if the current state matches the desired state
        if tabBarIsVisible == visible {
            return
        }
        
        // get a frame calculation ready
        let height = tabBarController!.tabBar.frame.size.height
        let offsetY = (visible ? -height : height)
        
        // zero duration means no animation
        let duration = (animated ? 0.2 : 0.0)
        
        UIView.animate(withDuration: duration, animations: {
            let frame = self.tabBarController!.tabBar.frame
            self.tabBarController!.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY);
        }, completion: nil)
        
    }
    
    var tabBarIsVisible: Bool {
        return tabBarController!.tabBar.frame.origin.y < view.frame.maxY
    }
    
    
    func showDateSearchView(_ show: Bool) {
        
        if show {
            dateSearchView.isHidden = false
        }
        
        dateSearchView.snp.remakeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            if show {
                view.top.equalTo(self.toolBarView.snp.bottom)
            } else {
                view.bottom.equalTo(self.view.snp.top)
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: { 
            self.view.layoutIfNeeded()
        }) { (complete) in
            if complete && !show {
                self.dateSearchView.isHidden = true
            }
        }
    }
    
    
    
    // MARK:- Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let apodVC = self.viewControllers?.first as? APODViewController {
            statusBarHidden = UIDevice.current.orientation.isLandscape || apodVC.isHidingDetail ? true : false
            statusBarBackgorundView.isHidden = UIDevice.current.orientation.isLandscape || apodVC.isHidingDetail ? true : false
        }
        
        coordinator.animate(alongsideTransition: { (context) in
            if let apodVC = self.viewControllers?.first as? APODViewController {
                apodVC.resetForRotation()
            }
        }) { (context) in
        }
    }
}


extension APODPageViewController: APODPageViewDelegate {
    
    func showToolTabStatusBars(_ show: Bool) {
        self.setToolBarVisible(visible: show, animated: true)
        self.statusBarHidden = UIDevice.current.orientation.isLandscape || !show ? true : false
        if self.pageViewType == .daily {
            self.setTabBarVisible(visible: show, animated: true)
        }
    }
}

extension APODPageViewController: ToolBarViewDelegate {
    
    func favoriteButtonTapped(sender: UIButton) {
        guard let vc = currentAPODViewController, let apod = vc.apod else { return }
        if apod.isFavorite {
            apodManager?.favorites.delete(apod)
        } else {
            apodManager?.favorites.save(apod)
        }
        toolBarView.setFavorite(apod.isFavorite)
    }
    
    func optionsButtonTapped(sender: UIButton) {
        print("burger tapped for \(currentAPODViewController!.date.displayString())")
        
//        let alertFactory = AlertFactory(for: self)
//        alertFactory.showActionSheet()
        
        let alert = UIAlertController(title: "Picture Options", message: "Not sure what this message should say, if anything at all.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let saveAction = UIAlertAction(title: "Save to Photos", style: .default) { (alertAction) in
            print("Now save that shit")
            
            guard let apodVC = self.currentAPODViewController, let image = apodVC.apodImageView.image else { return }
//            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            UIImageWriteToSavedPhotosAlbum(image, self, #selector (self.didFinishSavingImage(image: didFinishSavingWithError: contextInfo:)), nil)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }

        
    }
    func dateSearchButtonTapped(sender: UIButton) {
        showDateSearchView(dateSearchView.isHidden)
    }
    func dismissButtonTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didFinishSavingImage(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        print("FINISHED")
        let aleFac = AlertFactory(for: self)
        aleFac.showCustomOKAlert(title: "Success", message: "Photo Saved to Photos")
    }
}

