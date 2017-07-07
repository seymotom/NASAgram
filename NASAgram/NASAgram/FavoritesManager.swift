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

class FavoritesManager: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = FavoritesManager()
    private override init() {}
    
    var mainContext: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
       
    var fetchedResultsController: NSFetchedResultsController<FavAPOD>!
    
    func fetchAPOD(date: String, completion: @escaping (APOD?) -> Void) {
        fetchFavAPOD(date: date) { (favApod) in
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








