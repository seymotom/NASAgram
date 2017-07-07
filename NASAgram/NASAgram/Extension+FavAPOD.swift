//
//  Extension+FavAPOD.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/7/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

extension FavAPOD {
    
    func apod() -> APOD {
        return APOD(date: self.date!.date()!,
                        explanation: self.explanation!,
                        hdurl: self.hdurl,
                        url: self.url!,
                        mediaType: MediaType(rawValue: self.mediaType!)!,
                        serviceVersion: self.serviceVersion!,
                        title: self.title!,
                        copyright: self.copyright,
                        hdImageData: self.hdImageData,
                        ldImageData: self.ldImageData!)
    }
}
