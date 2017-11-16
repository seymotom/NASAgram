//
//  Extension+FavAPOD.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/7/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

extension FavAPOD {
    
    // FavAPOD doesn't need to know where the video came from as at this point there will be an image.
    
    func apod() -> APOD {
        let apod = APOD(date: date!.date()!,
                        explanation: explanation!,
                        hdurl: hdurl,
                        url: url!,
                        mediaType: MediaType.mediaType(myRawValue: mediaType!)!,
                        serviceVersion: serviceVersion!,
                        title: title!,
                        copyright: copyright,
                        hdImageData: hdImageData,
                        ldImageData: ldImageData)
        apod.isFavorite = true
        return apod
    }
    
    func populate(from apod: APOD) {
        date = apod.date.yyyyMMdd()
        title = apod.title
        explanation = apod.explanation
        serviceVersion = apod.serviceVersion
        mediaType = apod.mediaType.myRawValue
        copyright = apod.copyright
        url = apod.url
        hdurl = apod.hdurl
        hdImageData = apod.hdImageData
        ldImageData = apod.ldImageData
    }
}
