//
//  DailyPicPageViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

protocol APODDateDelegate {
    func dateSelected(date: Date)
}

class DailyPicPageViewController: UIPageViewController {
    
    var thisDate: Date = Date()
    
    var seenVCs: [String: UIViewController] = [:]
    
    let manager: APODManager!
    
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
    
    // put this in the dataManager
    func getAPODVC(for date: Date) -> UIViewController {
        if let nextVC = seenVCs[date.yyyyMMdd()] {
            return nextVC
        } else {
            let nextVC = APODViewController(date: date, dateDelegate: self, manager: manager, vcType: .daily)
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
    
    /*
 
    // fix the video screen. Currently loading indefinately and not showing info on didAppear
    
    */
    
    
    // better to handle rotation from pageVc as we can control just the currentVC and not the adjoining VCs
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // on rotate only toggle the tabBar for the current VC. Weird shit happens when toggleTabBar gets called for all VCs as the tabBar and statusBar are global singletons.
        guard let currentVC = viewControllers?.first as? APODViewController else {
            return
        }
        currentVC.toggleTabBar()
        
        coordinator.animate(alongsideTransition: { (context) in
            currentVC.apodImageView.resetForRotation()
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
        
        guard let currentVC = self.viewControllers?.first as? APODViewController else {
            return
        }
        // this increments or decrements the currentDate
        thisDate = currentVC.date
    }
}

extension DailyPicPageViewController: APODDateDelegate {
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

