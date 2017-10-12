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
    var dateSearchView: DateSearchView! { get }
    func showToolTabStatusBars(_ show: Bool)
    func dismissDateSearchView()
    var tabBarHeight:CGFloat { get }
}

class APODPageViewController: UIPageViewController {

    let apodManager: APODManager!
    
    var pageViewManager: APODPageViewManagerDelegate!
    
    let pageViewType: APODPageViewType
    
    let statusBarBackgorundView = BlurredBackgroundView(style: .dark)
    
    var toolBarView: ToolBarView!
    
    var dateSearchView: DateSearchView!
    
    var isFirstLoad = true
    
    var statusBarHidden = true {
        didSet {
            UIView.animate(withDuration: StyleManager.Animation.fadeDuration) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    let statusBarHeightWhenNotHidden: CGFloat
    
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.bounds.height ?? 0
    }
    
    var navBarDelegate: NavBarDelegate
    
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
    
    init(apodManager: APODManager, pageViewType: APODPageViewType, navBarDelegate: NavBarDelegate, indexPath: IndexPath? = nil) {
        self.apodManager = apodManager
        self.pageViewType = pageViewType
        self.navBarDelegate = navBarDelegate
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
        constrainViews(showing: false)
        setupPageVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fadeInView()
        if isFirstLoad, pageViewType == .daily {
            animateTabBarView(showing: false, animated: false)
        }
        isFirstLoad = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("/n/n/n>>>>>>>>>>> !!! MEMORY WARNING !!! <<<<<<<<<<<<<\n\n\n")
        // empty the dictionary if using too much memory
        pageViewManager.seenVCs = [:]
    }
    
    func fadeInView() {
        view.alpha = 0
        UIView.animate(withDuration: StyleManager.Animation.fadeDuration) {
            self.view.alpha = 1
        }
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
        view.addSubview(statusBarBackgorundView)
        view.addSubview(toolBarView)
        statusBarBackgorundView.isHidden = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? true : false
    }
    
    func constrainViews(showing: Bool) {
        constrainToolBarView(showing: showing)
        constrainStatusBarBackgroundView(showing: showing)
        constrainDateSearchView()
    }
    
    func constrainToolBarView(showing: Bool) {
        self.toolBarView.snp.remakeConstraints({ (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(navBarDelegate.navBarHeight)
            if showing {
                view.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                view.bottom.equalTo(self.view.snp.top)
            }
        })
    }
    
    func constrainStatusBarBackgroundView(showing: Bool) {
        statusBarBackgorundView.snp.remakeConstraints({ (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(statusBarHeightWhenNotHidden)
            if showing {
                view.top.equalToSuperview()
            } else {
                view.bottom.equalTo(self.view.snp.top)
            }
        })
    }
    
    func constrainDateSearchView(showing: Bool = false) {
        dateSearchView.snp.remakeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            if showing {
                view.top.equalTo(self.toolBarView.snp.bottom)
            } else {
                view.bottom.equalTo(self.view.snp.top)
            }
        }
    }
    
    
    // Animation Code
    
    func animateToolBarStatusBackgroundView(showing: Bool, animated: Bool) {
    
        // bail if the toolBarView hasn't been set yet
        if toolBarView == nil {
            return
        }
        if showing {
            toolBarView.isHidden = false
            statusBarBackgorundView.isHidden = false
        }
        constrainToolBarView(showing: showing)
        constrainStatusBarBackgroundView(showing: showing)

        // zero duration means no animation
        let duration = (animated ? StyleManager.Animation.slideDuration : 0)
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (complete) in
            if complete && !showing {
                self.toolBarView.isHidden = true
                self.statusBarBackgorundView.isHidden = true
            }
        })
    }
    
    func animateTabBarView(showing: Bool, animated: Bool) {
                
        if showing {
            tabBarController?.tabBar.isHidden = false
        }
        
        let tabBarIsShowing = tabBarController!.tabBar.frame.origin.y < view.frame.maxY
        // bail if the current state matches the desired state
        if tabBarIsShowing == showing {
            return
        }
        
        // get a frame calculation ready
        let height = tabBarController!.tabBar.frame.size.height
        let offsetY = (showing ? -height : height)
        
        // zero duration means no animation
        let duration = (animated ? StyleManager.Animation.slideDuration : 0)
        
        UIView.animate(withDuration: duration, animations: {
            let frame = self.tabBarController!.tabBar.frame
            self.tabBarController!.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY);
        }, completion: { (complete) in
            if complete && !showing {
                self.tabBarController?.tabBar.isHidden = true
            }
        })
    }
    
    func animateDateSearchView(showing: Bool) {
        if showing {
            dateSearchView.isHidden = false
        }
        constrainDateSearchView(showing: showing)
        UIView.animate(withDuration: StyleManager.Animation.slideDuration, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            if complete && !showing {
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
                DispatchQueue.main.async {
                    apodVC.resetForRotation()
                    self.constrainToolBarView(showing: !apodVC.isHidingDetail)
                    // ios 11, have to rehide the tabbar on rotation
                    if apodVC.isHidingDetail {
                        self.animateTabBarView(showing: false, animated: false)
                    }
                }
            }
        }) { (context) in
        }
    }
}


extension APODPageViewController: APODPageViewDelegate {
    
    func showToolTabStatusBars(_ show: Bool) {
        self.animateToolBarStatusBackgroundView(showing: show, animated: true)
        self.statusBarHidden = UIDevice.current.orientation.isLandscape || !show ? true : false
        if self.pageViewType == .daily {
            self.animateTabBarView(showing: show, animated: true)
        }
    }
    
    func dismissDateSearchView() {
        if !dateSearchView.isHidden {
            animateDateSearchView(showing: false)
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
        guard let apodVC = self.currentAPODViewController, let apodImage = apodVC.apodImageView.image, let apodTitle = apodVC.apod?.title else { return }
        print("\nimagesize ", apodImage.size, "\n")
        let activityController = UIActivityViewController(activityItems: [apodTitle, apodImage], applicationActivities: nil)
        activityController.excludedActivityTypes = [.assignToContact, .print]
        self.present(activityController, animated: true)
//        let alert = UIAlertController(title: "Picture Options", message: nil, preferredStyle: .actionSheet)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        let saveAction = UIAlertAction(title: "Save to Photos", style: .default) { (alertAction) in
//            UIImageWriteToSavedPhotosAlbum(apodImage, self, #selector (self.didFinishSavingImage(image: didFinishSavingWithError: contextInfo:)), nil)
//        }
//        alert.addAction(cancelAction)
//        alert.addAction(saveAction)
//        DispatchQueue.main.async {
//            self.present(alert, animated: true, completion: nil)
//        }
    }
    
    func dateSearchButtonTapped(sender: UIButton) {
        animateDateSearchView(showing: dateSearchView.isHidden)
    }
    func dismissButtonTapped(sender: UIButton) {
        apodManager.favorites.indexPath = pageViewManager.indexPath
        dismiss(animated: true, completion: nil)
    }
    
//    @objc func didFinishSavingImage(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: UnsafeMutableRawPointer?) {
//        print("FINISHED")
//        let aleFac = AlertFactory(for: self)
//        aleFac.showCustomOKAlert(title: "Success", message: "Photo Saved to Photos")
//    }
}

