//
//  APOD.swift
//  NASAgram
//
//  Created by Tom Seymour on 6/26/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case makeAPODError
}

enum MediaType: String {
    case image, video
}

enum APODField: String {
    case date, explanation, hdurl, title, url, copyright
    case mediaType = "media_type"
    case serviceVersion = "service_version"
}

class APOD {
    let date: Date
    let explanation: String
    let hdurl: String?
    let url: String
    let mediaType: MediaType
    let serviceVersion: String
    let title: String
    let copyright: String?
    
    var hdImageData: NSData?
    var ldImageData: NSData?
    
    var isFavorite: Bool = false
    
    init(date: Date, explanation: String, hdurl: String?, url: String,
         mediaType: MediaType, serviceVersion: String, title: String, copyright: String?,
         hdImageData: NSData? = nil, ldImageData: NSData? = nil) {
        self.date = date
        self.explanation = explanation
        self.hdurl = hdurl
        self.url = url
        self.mediaType = mediaType
        self.serviceVersion = serviceVersion
        self.title = title
        self.copyright = copyright
    }
    
    convenience init?(json: [String: AnyObject]) {
        guard
            let dateString = json[APODField.date.rawValue] as? String,
            let date = dateString.date(),
            let explanation = json[APODField.explanation.rawValue] as? String,
            let url = json[APODField.url.rawValue] as? String,
            let mediaTypeString = json[APODField.mediaType.rawValue] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let serviceVersion = json[APODField.serviceVersion.rawValue] as? String,
            let title = json[APODField.title.rawValue] as? String
            else {
                return nil
        }
        let hdurl = json[APODField.hdurl.rawValue] as? String
        let copyright = json[APODField.copyright.rawValue] as? String
        
        self.init(date: date, explanation: explanation, hdurl: hdurl, url: url, mediaType: mediaType, serviceVersion: serviceVersion, title: title, copyright: copyright)
    }
    
    static func makeAPOD(from data: Data) -> APOD? {
        do {
            let jsonData: Any = try JSONSerialization.jsonObject(with: data, options: [])
            guard
                let json = jsonData as? [String: AnyObject],
                let apod = APOD(json: json)
                else {
                    throw ParseError.makeAPODError
            }
            return apod
        }
        catch ParseError.makeAPODError {
            print("Error occured while making APOD")
        }
        catch let error as NSError {
            print("Error while parsing \(error)")
        }
        return nil
    }
    
}
