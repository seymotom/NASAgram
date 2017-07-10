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
    
    static let shared = FavoritesManager()
    private override init() {}
    
    var mainContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    var tableView: UITableView!
       
    var fetchedResultsController: NSFetchedResultsController<FavAPOD>!
    
    func fetchAPOD(date: String, completion: @escaping (APOD?) -> Void) {
        fetchFavAPOD(date: date) { (favApod) in
            DataManager.shared.appendAPOD(favApod?.apod())
            completion(favApod?.apod())
        }
    }
    
    func save(_ apod: APOD, completion: @escaping (Bool, Error?) -> Void) {
        
        let favApod = FavAPOD(context: mainContext)
        favApod.populate(from: apod)
        
        do {
            try mainContext.save()
        } catch let error {
            print("\n\n\n\(error)\n\n\n\n")
            completion(false, error)
            return
        }
        completion(true, nil)
    }
    
    func delete(_ apod: APOD, completion: @escaping (Bool) -> Void) {
        fetchFavAPOD(date: apod.date.yyyyMMdd()) { (favApod) in
            if let validFavApod = favApod {
                self.mainContext.delete(validFavApod)
                do {
                    try self.mainContext.save()
                } catch {
                    fatalError("Failed to delete apod: \(error)")
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func fetchFavAPOD(date: String, completion: @escaping (FavAPOD?) -> Void) {
        let request: NSFetchRequest<FavAPOD> = FavAPOD.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "date = %@", date)
        request.predicate = predicate
        do {
            let favApods = try mainContext.fetch(request) 
            if favApods.isEmpty {
                completion(nil)
            } else {
                completion(favApods.last!)
            }
        } catch {
            fatalError("Failed to search for apod in core data: \(error)")
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
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

}

extension FavoritesManager: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { fatalError("No sections in fetched results controller")}
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
        let favAPOD = fetchedResultsController.object(at: indexPath)
        
        
        cell.textLabel?.text = favAPOD.apod().date.displayString()
        return cell
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
            let date = favApod.date!
            mainContext.delete(favApod)
            do {
                try mainContext.save()
                DataManager.shared.removeFavorite(for: date)
            } catch let error {
                fatalError("Failed to save context: \(error)")
            }
        }
        initializeFetchedResultsController()
    }
    
}








