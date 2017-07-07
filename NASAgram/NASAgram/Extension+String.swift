//
//  Extension+String.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/7/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

extension String {
    
    func date() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}
