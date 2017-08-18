//
//  DailyPicPageViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

protocol APODPageViewDelegate {
    var statusBarHeightWhenNotHidden: CGFloat { get }
    func showToolTabStatusBars(_ show: Bool)
}

class DailyPicPageViewController: UIPageViewController {
    
    var thisDate: Date = Date()
    
    var seenVCs: [String: UIViewController] = [:]
    
    let manager: APODManager!
    
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
    
    init(manager: APODManager) {
        self.manager = manager
        // StatusBar height is 0 when hidden so have to capture the value here so the APODVC can use it to constrain the date
        statusBarHeightWhenNotHidden = UIApplication.shared.statusBarFrame.height
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        toolBarView = ToolBarView(delegate: self, vcType: .daily)
        view.addSubview(toolBarView)
        dateSearchView = DateSearchView(delegate: self)
        view.addSubview(dateSearchView)
        dateSearchView.isHidden = true
        view.addSubview(statusBarBackgorundView)
    }
    
    func setupConstraints() {
        toolBarView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(ToolBarView.height)
            view.bottom.equalTo(self.view.snp.top)
        }
        statusBarBackgorundView.snp.makeConstraints { (view) in
            view.leading.trailing.top.equalToSuperview()
            view.bottom.equalTo(topLayoutGuide.snp.bottom)
        }
        dateSearchView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            view.top.equalTo(toolBarView.snp.bottom)
        }
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
    
    
    // MARK:- Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let apodVC = self.viewControllers?.first as? APODViewController {
            statusBarHidden = UIDevice.current.orientation.isLandscape || apodVC.isHidingDetail ? true : false
        }
        
        coordinator.animate(alongsideTransition: { (context) in
            if let apodVC = self.viewControllers?.first as? APODViewController {
                apodVC.resetForRotation()
            }
        }) { (context) in
        }
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
        
        guard let currentVC = currentAPODViewController else {
            return
        }
        // this increments or decrements the currentDate
        thisDate = currentVC.date
    }
}

extension DailyPicPageViewController: APODPageViewDelegate {
    
    func setToolBarVisible(visible: Bool, animated: Bool) {
        
        // bail if the current state matches the desired state
        if toolBarViewIsVisible == visible {
            return
        }
        
        // zero duration means no animation
        let duration = (animated ? 0.2 : 0.0)
        self.toolBarView.snp.remakeConstraints({ (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(50)
            if visible {
                view.top.equalTo(self.topLayoutGuide.snp.bottom)
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

extension DailyPicPageViewController: DateSearchViewDelegate {
    func dateSelected(date: Date) {
        guard date != thisDate else { return }
        let direction: UIPageViewControllerNavigationDirection = date < thisDate ? .reverse : .forward
        let newVC = getAPODVC(for: date)
        setViewControllers([newVC], direction: direction, animated: true) { (_) in
            self.loadSurroundingVCs(for: date, viewController: newVC)
        }
        thisDate = date
    }
}

extension DailyPicPageViewController: ToolBarViewDelegate {
    
    func favoriteButtonTapped(sender: UIButton) {
        print("fav tapped for \(currentAPODViewController!.date.displayString())")
        
        guard let vc = currentAPODViewController, let apod = vc.apod else { return }
        
        if apod.isFavorite {
            manager?.favorites.delete(apod)
        } else {
            manager?.favorites.save(apod)
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
        dismiss(animated: true, completion: nil)
    }
}

