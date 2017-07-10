//
//  DataManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/26/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

class DataManager {
    
    static let shared = DataManager()
    private init() {}
    
    private(set) var apods: [APOD] = []
    
    private static let validEndpoint = "https://api.nasa.gov/planetary/apod?api_key=AOy2RZcIA1OYQZF6Bbjjz5ntTJPSPwYogYtN0IGP&hd=True&date=2016-11-07"
    
    let apodEndpoint = "https://api.nasa.gov/planetary/apod?api_key=AOy2RZcIA1OYQZF6Bbjjz5ntTJPSPwYogYtN0IGP&hd=True&date="
    
    func apod(for date: String) -> APOD? {
        return apods.filter{ $0.date.yyyyMMdd() == date }.first
    }
    
    func appendAPOD(_ apod: APOD?) {
        if let apod = apod {
            apods.append(apod)
        }
    }

    
    func removeFavorite(for date: String) {
        let optionalAPOD = apods.filter{ $0.date.yyyyMMdd() == date }.first
        if let apod = optionalAPOD {
            apod.isFavorite = false
        }
    }
    
    
    // probably wanna add an error to these completion handlers
    func getAPOD(from date: Date, completion: @escaping (APOD) -> ()) {
        APIManager.shared.getData(endpoint: apodEndpoint + date.yyyyMMdd()) { (data) in
            if let apod = APOD.makeAPOD(from: data) {
                self.apods.append(apod)
                completion(apod)
            }
        }
    }
    
    func getImage(url: String, completion: @ escaping (Data) -> ()) {
        APIManager.shared.getData(endpoint: url) { (data) in
            completion(data)
        }
    }
    
}
