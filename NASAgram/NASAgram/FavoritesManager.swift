//
//  FavoritesManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/6/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FavoritesManager: NSObject {
    
    let dataManager: DataManager!
    
    var mainContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    var tableView: UITableView!
    var favoritesViewController: FavoritesViewController!
    var fetchedResultsController: NSFetchedResultsController<FavAPOD>!
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    func fetchAPOD(date: String) -> APOD? {
        let apod = fetchFavAPOD(date: date)?.apod()
        dataManager.appendAPOD(apod)
        return apod        
    }

    func save(_ apod: APOD) {
        let favApod = FavAPOD(context: mainContext)
        favApod.populate(from: apod)
        do {
            try mainContext.save()
        } catch let error {
            fatalError("Failed to save apod in core data: \(error)")
        }
        dataManager.updateFavorite(for: favApod.date!, isFavorite: true)
    }
    
    func delete(_ apod: APOD) {
        if let favApod = fetchFavAPOD(date: apod.date.yyyyMMdd()) {
            deleteFromCoreData(favApod: favApod)
        }
    }
    
    private func fetchFavAPOD(date: String) -> FavAPOD? {
        let request: NSFetchRequest<FavAPOD> = FavAPOD.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "date = %@", date)
        request.predicate = predicate
        do {
            let favApods = try mainContext.fetch(request) 
            return favApods.last
        } catch {
            fatalError("Failed to search for apod in core data: \(error)")
        }
    }
    
    fileprivate func deleteFromCoreData(favApod: FavAPOD) {
        let date = favApod.date!
        self.mainContext.delete(favApod)
        do {
            try self.mainContext.save()
            dataManager.updateFavorite(for: date, isFavorite: false)
        } catch {
            fatalError("Failed to delete apod: \(error)")
        }
    }
    
    
    // debug function
    func printAllSavedFavDates() {
        let request: NSFetchRequest<FavAPOD> = FavAPOD.fetchRequest()
        do {
            let favApods = try mainContext.fetch(request) 
            print("\nHere are the \(favApods.count) favorites")
            for fav in favApods {
                print(fav.date!)
            }
            print("\n")
        } catch {
            fatalError("Failed to search for all apods in core data:\n\n \(error)")
        }
    }
}

extension FavoritesManager: NSFetchedResultsControllerDelegate {
    
    func initializeFetchedResultsController() {
        let request: NSFetchRequest<FavAPOD> = FavAPOD.fetchRequest()
        let dateSort = NSSortDescriptor(key: #keyPath(FavAPOD.date), ascending: false)
        request.sortDescriptors = [dateSort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("failed to initialize fetchedResults controller")
        }
        tableView.reloadData()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .left)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
}

extension FavoritesManager: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetched results controller")
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesTableViewCell.identifier, for: indexPath) as! FavoritesTableViewCell
        let apod = fetchedResultsController.object(at: indexPath).apod()
        cell.configure(with: apod)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let apodManager = APODManager(dataManager: dataManager, favoritesManager: self)
        let favoritesPVC = APODPageViewController(apodManager: apodManager, pageViewType: .favorite, indexPath: indexPath)
        favoritesViewController.present(favoritesPVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let favApod = fetchedResultsController.object(at: indexPath)
            deleteFromCoreData(favApod: favApod)
        }
    }
}








