//
//  DailyPageViewManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 8/18/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import Foundation

protocol APODPageViewManagerDelegate: UIPageViewControllerDelegate, UIPageViewControllerDataSource, DateSearchViewDelegate {
    func setupPageVC()
    func dateSelected(date: Date)
    var indexPath: IndexPath? { get set }
}

class DailyPageViewManager: NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource, APODPageViewManagerDelegate {
    
    var thisDate: Date = Date()
    
    var indexPath: IndexPath?
    
    let apodPageViewController: APODPageViewController!
    let apodManager: APODManager!
    
    var seenVCs: [String: UIViewController] = [:]
    
    init(pageViewController: APODPageViewController, apodManager: APODManager) {
        apodPageViewController = pageViewController
        self.apodManager = apodManager
    }
    
    
    func setupPageVC() {
        let todayVC = getAPODVC(for: thisDate)
        apodPageViewController.setViewControllers([todayVC], direction: .reverse, animated: true) { (_) in
            self.loadSurroundingVCs(for: self.thisDate, viewController: todayVC)
        }
        seenVCs[thisDate.yyyyMMdd()] = todayVC
    }
    
    
    func getAPODVC(for date: Date) -> UIViewController {
        if let nextVC = seenVCs[date.yyyyMMdd()] {
            return nextVC
        } else {
            let nextVC = APODViewController(date: date, pageViewDelegate: apodPageViewController, manager: apodManager)
            seenVCs[date.yyyyMMdd()] = nextVC
            return nextVC
        }
    }
    
    func loadSurroundingVCs(for date: Date, viewController: UIViewController) {
        let before = pageViewController(apodPageViewController, viewControllerBefore: viewController)
        let after = pageViewController(apodPageViewController, viewControllerAfter: viewController)
        // accessing the viewController's view loads it so it can prepopulate
        let _ = before?.view
        let _ = after?.view
        
        seenVCs[date.advanceDay(by: -1).yyyyMMdd()] = before
        seenVCs[date.advanceDay(by: 1).yyyyMMdd()] = after
    }
    
    func dateSelected(date: Date) {
        guard date != thisDate else { return }
        
        apodPageViewController.showDateSearchView(false)
        
        let direction: UIPageViewControllerNavigationDirection = date < thisDate ? .reverse : .forward
        let newVC = getAPODVC(for: date)
        apodPageViewController.setViewControllers([newVC], direction: direction, animated: true) { (_) in
            self.loadSurroundingVCs(for: date, viewController: newVC)
        }
        thisDate = date
    }
    
    
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let currentVC = self.apodPageViewController.currentAPODViewController else {
            return
        }
        // this increments or decrements the currentDate
        thisDate = currentVC.date
    }
}
