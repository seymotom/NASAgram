//
//  APIManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/26/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

class APIManager {
    
    func getData(endpoint: String, completion: @escaping (Data?, String?) -> Void) {
        guard let url = URL(string: endpoint) else { return }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("Error durring session: \(String(describing: error))")
                completion(nil, error.localizedDescription)
            }
            else if let response = response as? HTTPURLResponse {
                let success = response.statusCode / 100 == 2
                if success {
                    completion(data, nil)
                }
                else {
                    completion(nil, HTTPURLResponse.localizedString(forStatusCode: response.statusCode))
//                    completion(nil, response.description)

                }
            }
            }.resume()
    }
}
