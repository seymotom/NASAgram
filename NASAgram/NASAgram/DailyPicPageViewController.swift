//
//  DailyPicPageViewController.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/27/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class DailyPicPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, APODViewDelegate {
    
    var thisDate: Date = Date()
    
    var seenVCs: [String: APODViewController] = [:]

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
        
        let todayVC = APODViewController(date: thisDate, delegate: self)
        setViewControllers([todayVC], direction: .reverse, animated: true, completion: nil)
        seenVCs[thisDate.apodURI()] = todayVC
    }
    
    
    // data source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if thisDate.apodURI() == Date().apodURI() {
            return nil
        }
        
        let tomorrow = thisDate.advanceDay(by: 1)
        return getAPODVC(for: tomorrow)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let yesterday = thisDate.advanceDay(by: -1)
        return getAPODVC(for: yesterday)
    }
    
    
    // put this in the dataManager
    func getAPODVC(for date: Date) -> APODViewController {
        if let nextVC = seenVCs[date.apodURI()] {
            return nextVC
        } else {
            let nextVC = APODViewController(date: date, delegate: self)
            seenVCs[date.apodURI()] = nextVC
            return nextVC
        }
    }
    
    // delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
                
        guard let currentVC = self.viewControllers?.first as? APODViewController else {
            return
        }
        // this increments or decrements the currentDate
        thisDate = currentVC.date
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    
    // apod View delegate
    
    func dateSelected(date: Date) {
        guard date != thisDate else { return }
        let direction: UIPageViewControllerNavigationDirection = date < thisDate ? .reverse : .forward
        setViewControllers([getAPODVC(for: date)], direction: direction, animated: true, completion: nil)
        thisDate = date
    }
    

    
}
