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
    
    static let firstAPODDate = "1995-06-20".date()!
    
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
    
    func getAPOD(from date: Date, completion: @escaping (APOD?, String?) -> ()) {
        apiManager.getData(endpoint: apodEndpoint + date.yyyyMMdd()) { (data, errorMessage) in
            if let error = errorMessage {
                completion(nil, error)
                print("\nERROR GETTING APOD FOR \(date.yyyyMMdd())\n")

            }
            else if let data = data, let apod = APOD.makeAPOD(from: data) {
                print("\nGOT APOD FOR \(apod.date.yyyyMMdd())\n")
                self.apods.append(apod)
                
                switch apod.mediaType {
                case .video(let videoType):
                    if let videoType = videoType {
                        switch videoType {
                        case .unknown, .youTube:
                            completion(apod, nil)
                        case .vimeo:
                            self.getVimeoImageURL(for: apod, completion: { (urlString, errorMessage) in
                                if let error = errorMessage {
                                    completion(apod, error)
                                } else {
                                    apod.hdurl = urlString
                                    completion(apod, nil)
                                }
                            })
                        }                        
                    }
                case .image:
                    completion(apod, nil)
                }
            }
        }
    }
    
    func getVimeoImageURL(for apod: APOD, completion: @ escaping (String?, String?) -> ()) {
        
        if let vimeoEndpoint = MediaType.VideoType.vimeoImageAPIEndpoint(urlString: apod.url) {
            apiManager.getData(endpoint: vimeoEndpoint) { (data, errorMessage) in
                if let error = errorMessage {
                    completion(nil, error)
                }
                else if let data = data, let urlString = MediaType.VideoType.vimeoImageURL(from: data) {
                    completion(urlString, nil)
                }
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
