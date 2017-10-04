//
//  StyleManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 9/28/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class StyleManager {
    
    static let appTitle = "NASAgram"
    
    class Icon {
        
        static let daily: UIImage? = UIImage(named: "daily")
        static let favorites: UIImage? = UIImage(named: "favorites")
        
        static let dismiss: UIImage? = UIImage(named: "dismiss")
        static let menu: UIImage? = UIImage(named: "menu")
        static let search: UIImage? = UIImage(named: "search")
        static let favoriteEmpty: UIImage? = UIImage(named: "starEmpty")
        static let favoriteFilled: UIImage? = UIImage(named: "starFilled")

    }
    
    class Font {
        static let titileSize: CGFloat = 20.0
        
        static func nasalization(size: CGFloat = Font.titileSize) -> UIFont {
            return UIFont(name: "NasalizationRg-Regular", size: size)!
        }
    }
    
    
    class Dimension {
        
    }
    
    
    
}
