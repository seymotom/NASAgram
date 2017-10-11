//
//  MediaType.swift
//  NASAgram
//
//  Created by Tom Seymour on 9/20/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

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
            let postIDURLString = ".json"
            
            if let idSection = urlString.components(separatedBy: "/").last,
                let id = idSection.components(separatedBy: "#").first {
                return preIDURLString + id + postIDURLString
            }
            return nil
        }
        
        static func vimeoImageURL(from data: Data) -> String? {
            let vimeoThumbnailField = "thumbnail_large"
            do {
                let jsonData: Any = try JSONSerialization.jsonObject(with: data, options: [])
                guard
                    let jsonArr = jsonData as? [[String: AnyObject]],
                    let vidDict = jsonArr.first,
                    let imageURLString = vidDict[vimeoThumbnailField] as? String
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
    
    static let imageRawValue = "image"
    static let videoRawValue = "video"
    
    var myRawValue: String {
        switch self {
        case .image:
            return MediaType.imageRawValue
        case .video:
            return MediaType.videoRawValue
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
        case MediaType.imageRawValue:
            return .image
        case MediaType.videoRawValue:
            return .video(nil)
        default:
            return nil
        }
    }
}

