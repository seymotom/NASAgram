//
//  DataManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/26/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

class DataManager {
    
    private let apiManager: APIManager!
    
    private(set) var apods: [APOD] = []
    
    private let apodEndpoint = "https://api.nasa.gov/planetary/apod?api_key=AOy2RZcIA1OYQZF6Bbjjz5ntTJPSPwYogYtN0IGP&hd=True&date="
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    func apod(for date: String) -> APOD? {
        return apods.filter{ $0.date.yyyyMMdd() == date }.first
    }
    
    func appendAPOD(_ apod: APOD?) {
        if let apod = apod {
            apods.append(apod)
        }
    }

    func updateFavorite(for date: String, isFavorite: Bool) {
        let optionalAPOD = apods.filter{ $0.date.yyyyMMdd() == date }.first
        if let apod = optionalAPOD {
            apod.isFavorite = isFavorite
        }
    }
    
    // probably wanna add an error to these completion handlers
    func getAPOD(from date: Date, completion: @escaping (APOD?, String?) -> ()) {
        apiManager.getData(endpoint: apodEndpoint + date.yyyyMMdd()) { (data, errorMessage) in
            if let error = errorMessage {
                completion(nil, error)
            }
            else if let data = data, let apod = APOD.makeAPOD(from: data) {
                self.apods.append(apod)
                completion(apod, nil)
            }
        }
    }
    
    func getImage(url: String, completion: @ escaping (Data?, String?) -> ()) {
        apiManager.getData(endpoint: url) { (data, errorMessage) in
            if let error = errorMessage {
                completion(nil, error)
            }
            else {
                completion(data, nil)
            }
        }
    }
}
