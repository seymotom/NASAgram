//
//  APODPageViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 8/18/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

enum APODPageViewType {
    case daily, favorite
}

protocol APODPageViewDelegate {
    var statusBarHeightWhenNotHidden: CGFloat { get }
    func showToolTabStatusBars(_ show: Bool)
    var toolBarView: ToolBarView! { get }
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
        navigationController?.navigationBar.isHidden = true
        setupPageVC()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("/n/n/n>>>>>>>>>>> !!! MEMORY WARNING !!! <<<<<<<<<<<<<\n\n\n")
        // empty the dictionary if using too much memory
        //        seenVCs = [:]
    }
    
    func setupPageVC() {
        dataSource = pageViewManager
        delegate = pageViewManager
        pageViewManager.setupPageVC()
    }
    
    func setupView() {
        toolBarView = ToolBarView(delegate: self, pageViewType: pageViewType)
        view.addSubview(toolBarView)
        dateSearchView = DateSearchView(delegate: pageViewManager)
        view.addSubview(dateSearchView)
        dateSearchView.isHidden = true
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
            view.top.equalTo(toolBarView.snp.bottom)
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
    
    
    func setToolBarVisible(visible: Bool, animated: Bool) {
        
        // bail if the current state matches the desired state
        if toolBarViewIsVisible == visible {
            return
        }
        
        // zero duration means no animation
        let duration = (animated ? 0.2 : 0.0)
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
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    var toolBarViewIsVisible: Bool {
        guard toolBarView != nil else { return false }
        return toolBarView.frame.origin.y >= view.frame.origin.y
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
    
    func showToolTabStatusBars(_ show: Bool) {
        setToolBarVisible(visible: show, animated: true)
        setTabBarVisible(visible: show, animated: true)
        statusBarHidden = UIDevice.current.orientation.isLandscape || !show ? true : false
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
    }
    func dateSearchButtonTapped(sender: UIButton) {
        dateSearchView.isHidden = dateSearchView.isHidden ? false : true
    }
    func dismissButtonTapped(sender: UIButton) {
//        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
}

