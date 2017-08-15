//
//  DailyPicPageViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

protocol APODPageViewDelegate {
    func dateSelected(date: Date)
    var statusBarHidden: Bool { get set }
    func setNavbarVisible(visible: Bool, animated: Bool, completion: @escaping (Bool) -> Void)
    func setTabBarVisible(visible: Bool, animated: Bool, completion: @escaping (Bool) -> Void)
    
}

class DailyPicPageViewController: UIPageViewController {
    
    var thisDate: Date = Date()
    
    var seenVCs: [String: UIViewController] = [:]
    
    let manager: APODManager!
    
//    let statusBarBackgorundView = BlurredBackgroundView(style: .dark)
    
    var navbarView: ToolBarView!
    
    var statusBarHidden = true {
        didSet {
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
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
    
    init(manager: APODManager) {
        self.manager = manager
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageVC()
        setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTabBarVisible(visible: false, animated: false) { (_) in }
        setNavbarVisible(visible: false, animated: false) { (_) in }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("/n/n/n>>>>>>>>>>> !!! MEMORY WARNING !!! <<<<<<<<<<<<<\n\n\n")
        // empty the dictionary if using too much memory
        seenVCs = [:]
    }
    
    func setupPageVC() {
        dataSource = self
        delegate = self
        
        let todayVC = getAPODVC(for: thisDate)
        setViewControllers([todayVC], direction: .reverse, animated: true) { (_) in
            self.loadSurroundingVCs(for: self.thisDate, viewController: todayVC)
        }
        seenVCs[thisDate.yyyyMMdd()] = todayVC
    }
    
    func setupView() {
        guard let currentVC = self.viewControllers?.first as? APODViewController else {
            return
        }
        
        navbarView = ToolBarView(delegate: currentVC.apodInfoView, vcType: .daily)
        view.addSubview(navbarView)
        
        
        navbarView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalToSuperview()
            view.height.equalTo(50)
        }
        
//        view.addSubview(statusBarBackgorundView)
//        statusBarBackgorundView.snp.makeConstraints { (view) in
//            view.leading.trailing.top.equalToSuperview()
//            view.bottom.equalTo(topLayoutGuide.snp.bottom)
//        }
    }
    
    // put this in the dataManager
    func getAPODVC(for date: Date) -> UIViewController {
        if let nextVC = seenVCs[date.yyyyMMdd()] {
            return nextVC
        } else {
            let nextVC = APODViewController(date: date, pageViewDelegate: self, manager: manager, vcType: .daily)
            seenVCs[date.yyyyMMdd()] = nextVC
            return nextVC
        }
    }
    
    func loadSurroundingVCs(for date: Date, viewController: UIViewController) {
        let before = pageViewController(self, viewControllerBefore: viewController)
        let after = pageViewController(self, viewControllerAfter: viewController)
        // accessing the viewController's view loads it so it can prepopulate
        let _ = before?.view
        let _ = after?.view
        
        seenVCs[date.advanceDay(by: -1).yyyyMMdd()] = before
        seenVCs[date.advanceDay(by: 1).yyyyMMdd()] = after
    }
    
    
    

    
    
    
}

extension DailyPicPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if thisDate.yyyyMMdd() == Date().yyyyMMdd() {
            return nil
        }
        let tomorrow = thisDate.advanceDay(by: 1)
        return getAPODVC(for: tomorrow)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let yesterday = thisDate.advanceDay(by: -1)
        return getAPODVC(for: yesterday)
    }
}

extension DailyPicPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let currentVC = self.viewControllers?.first as? APODViewController else {
            return
        }
        // this increments or decrements the currentDate
        thisDate = currentVC.date
    }
}

extension DailyPicPageViewController: APODPageViewDelegate {
    
    func setNavbarVisible(visible: Bool, animated: Bool, completion: @escaping (Bool) -> Void) {
        
        guard let vc = viewControllers?.first as? APODViewController else { return }
        
        print("VC for \(vc.date.displayString()) is set to visible: \(visible) ")
        
        
        // bail if the current state matches the desired state
        if navbarIsVisible == visible {
            return
        }
        
        // get a frame calculation ready
        let height = navbarView.frame.size.height
        let offsetY = (visible ? height : -height)
        
        // zero duration means no animation
        let duration = (animated ? 0.2 : 0.0)
        
        print("animated = \(animated)")
        
        UIView.animate(withDuration: duration, animations: {
            let frame = self.navbarView.frame
            self.navbarView.frame = frame.offsetBy(dx: 0, dy: offsetY);
        }, completion:completion)
        
        
    }
    
    var navbarIsVisible: Bool {
        if navbarView == nil {
            print("navbarView is nil")
            return false
        }
        return navbarView.frame.origin.y >= view.frame.origin.y
    }

    
    func setTabBarVisible(visible: Bool, animated: Bool, completion: @escaping (Bool) -> Void) {
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
        }, completion:completion)
    }
    
    var tabBarIsVisible: Bool {
        return tabBarController!.tabBar.frame.origin.y < view.frame.maxY
    }

    func dateSelected(date: Date) {
        guard date != thisDate else { return }
        let direction: UIPageViewControllerNavigationDirection = date < thisDate ? .reverse : .forward
        let thisVC = getAPODVC(for: date)
        setViewControllers([thisVC], direction: direction, animated: true) { (_) in
            self.loadSurroundingVCs(for: date, viewController: thisVC)
        }
        thisDate = date
    }
    
}

