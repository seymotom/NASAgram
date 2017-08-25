//
//  FavoritesPageViewManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 8/19/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class FavoritesPageViewManager: NSObject {
    
    var indexPath: IndexPath?

    let apodPageViewController: APODPageViewController!
    let apodManager: APODManager!
    
    init(pageViewController: APODPageViewController, apodManager: APODManager, indexPath: IndexPath?) {
        apodPageViewController = pageViewController
        self.indexPath = indexPath
        self.apodManager = apodManager
    }
    
    func getAPODVC(for indexPath: IndexPath) -> UIViewController? {
        // need to check indexPath
        guard
            let fetchedResultsController = apodManager.favorites.fetchedResultsController,
            let sections = fetchedResultsController.sections,
            let sectionInfo = sections.first,
            indexPath.row < sectionInfo.numberOfObjects,
            indexPath.row >= 0
            else { return nil }
        
        let apod = fetchedResultsController.object(at: indexPath).apod()
        let apodVC = APODViewController(date: apod.date, pageViewDelegate: apodPageViewController, manager: apodManager)
        apodVC.indexPath = indexPath
        return apodVC
    }


}

extension FavoritesPageViewManager: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let currentVC = self.apodPageViewController.currentAPODViewController, let indexPath = currentVC.indexPath else {
            return
        }
        
        self.indexPath = indexPath
    }
}


extension FavoritesPageViewManager: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let indexPath = indexPath else { return nil }
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        return getAPODVC(for: nextIndexPath)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let indexPath = indexPath else { return nil }
        let nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        return getAPODVC(for: nextIndexPath)
    }

}

extension FavoritesPageViewManager: APODPageViewManagerDelegate {
    
    func setupPageVC() {
//        let todayVC = getAPODVC(for: thisDate)
//        apodPageViewController.setViewControllers([todayVC], direction: .reverse, animated: true) { (_) in
//            self.loadSurroundingVCs(for: self.thisDate, viewController: todayVC)
//        }
//        seenVCs[thisDate.yyyyMMdd()] = todayVC
        guard let indexPath = indexPath, let thisVC = getAPODVC(for: indexPath) else { return }
        
        print("should be good")
        apodPageViewController.setViewControllers([thisVC], direction: .reverse, animated: true, completion: nil)
    }
    
    func dateSelected(date: Date) {
//        guard date != thisDate else { return }
//        let direction: UIPageViewControllerNavigationDirection = date < thisDate ? .reverse : .forward
//        let newVC = getAPODVC(for: date)
//        apodPageViewController.setViewControllers([newVC], direction: direction, animated: true) { (_) in
//            self.loadSurroundingVCs(for: date, viewController: newVC)
//        }
//        thisDate = date
    }

    
}
