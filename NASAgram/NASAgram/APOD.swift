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
    case vimeoImageError
}

enum MediaType {
    
    enum VideoType: String {
        case youTube, vimeo, unknown
        
        static func youTubeImageURL(urlString: String) -> String? {
            let preIDURLString = "https://img.youtube.com/vi/"
            let postIDURLString = "/0.jpg"
            
            if let idSection = urlString.components(separatedBy: "/").last,
                let id = idSection.components(separatedBy: "?").first {
                return preIDURLString + id + postIDURLString
            }
            
            return nil
        }
        
        static func vimeoImageAPIEndpoint(urlString: String) -> String? {
            let preIDURLString = "https://vimeo.com/api/v2/video/"
            let postIDURLString = ".jsonX"
            
            if let idSection = urlString.components(separatedBy: "/").last,
                let id = idSection.components(separatedBy: "#").first {
                return preIDURLString + id + postIDURLString
            }
            
            return nil
        }
        
        static func vimeoImageURL(from data: Data) -> String? {
            do {
                let jsonData: Any = try JSONSerialization.jsonObject(with: data, options: [])
                guard
                    let jsonArr = jsonData as? [[String: AnyObject]],
                    let vidDict = jsonArr.first,
                    let imageURLString = vidDict["thumbnail_large"] as? String
                    else {
                        throw ParseError.vimeoImageError
                }
                return imageURLString
            }
            catch ParseError.vimeoImageError {
                print("Error occured while getting vimeo image")
            }
            catch let error as NSError {
                print("Error while parsing \(error)")
            }
            return nil
            
        }


    }
    
    case image
    case video(VideoType?)
    
    var myRawValue: String {
        switch self {
        case .image:
            return "image"
        case .video:
            return "video"
        }
    }
    
    static func videoType(from urlString: String) -> VideoType {
        if urlString.contains(VideoType.vimeo.rawValue) {
            return .vimeo
        } else if urlString.contains(VideoType.youTube.rawValue.lowercased()) {
            return .youTube
        } else {
            return .unknown
        }
    }
    
    static func mediaType(myRawValue: String) -> MediaType? {
        switch myRawValue {
        case "image":
            return .image
        case "video":
            return .video(nil)
        default:
            return nil
        }
    }
}


enum APODField: String {
    case date, explanation, hdurl, title, url, copyright
    case mediaType = "media_type"
    case serviceVersion = "service_version"
}

class APOD {
    let date: Date
    let explanation: String
    var hdurl: String?
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
        self.hdImageData = hdImageData
        self.ldImageData = ldImageData
    }
    
    convenience init?(json: [String: AnyObject]) {
        guard
            let dateString = json[APODField.date.rawValue] as? String,
            let date = dateString.date(),
            let explanation = json[APODField.explanation.rawValue] as? String,
            let url = json[APODField.url.rawValue] as? String,
            let mediaTypeString = json[APODField.mediaType.rawValue] as? String,
            var mediaType = MediaType.mediaType(myRawValue: mediaTypeString),
            let serviceVersion = json[APODField.serviceVersion.rawValue] as? String,
            let title = json[APODField.title.rawValue] as? String
            else {
                return nil
        }
        let copyright = json[APODField.copyright.rawValue] as? String
        
        let hdurlString = json[APODField.hdurl.rawValue] as? String
        var hdurl: String?
        
        switch mediaType {
        case .image:
            hdurl = hdurlString
        case .video:
            switch MediaType.videoType(from: url) {
            case .youTube:
                hdurl = MediaType.VideoType.youTubeImageURL(urlString: url)
                mediaType = .video(.youTube)
            case .vimeo:
                 mediaType = .video(.vimeo)
            case .unknown:
                mediaType = .video(.unknown)
            }
        }
        
        
        
//        let hdurl = mediaType == .image ? json[APODField.hdurl.rawValue] as? String : APOD.getVideoImageURL(urlString: url)
        
        
        self.init(date: date, explanation: explanation, hdurl: hdurl, url: url, mediaType: mediaType, serviceVersion: serviceVersion, title: title, copyright: copyright)
    }
    
    
//    static private func getVideoImageURL(urlString: String) -> String {
//        // detect if youtube or vimeo
//        
//        // if vimeo, make a network call. May need to add a field to the model, maybe have an associated value to MediaType.video of type VideoType. Can make cases for youTube, vimeo and unknown.   
//        
//        
//        
//        return ""
//    }
    
    
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
