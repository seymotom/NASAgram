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
    
    static let validEndpoint = "https://api.nasa.gov/planetary/apod?api_key=AOy2RZcIA1OYQZF6Bbjjz5ntTJPSPwYogYtN0IGP&hd=True&date=2016-11-07"
    
    let apodEndpoint = "https://api.nasa.gov/planetary/apod?api_key=AOy2RZcIA1OYQZF6Bbjjz5ntTJPSPwYogYtN0IGP&hd=True&date="
    
    
    // probably wanna add an error to these completion handlers
    func getAPOD(from date: Date, completion: @escaping (APOD) -> ()) {
        APIManager.shared.getData(endpoint: apodEndpoint + date.apodURI()) { (data) in
            if let apod = APOD.makeAPOD(from: data) {
                completion(apod)
            }
        }
    }
    
}
