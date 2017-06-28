//
//  APIManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/26/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

class APIManager {
    
    static let shared = APIManager()
    private init() {}
    
    func getData(endpoint: String, completion: @escaping (Data) -> Void) {
        guard let myURL = URL(string: endpoint) else { return }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: myURL) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("Error durring session: \(String(describing: error))")
            }
            if let validData = data {
                completion(validData)
            }
            }.resume()
    }
}
