//
//  StyleManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 9/28/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class StyleManager {
    
    
    class Text {
        static let appTitle = "NASAgram"
        
        static let videoPlayExplanation = "open video in browser?"

    }
    
    class Icon {
        
        static let daily = UIImage(named: "daily")
        static let favorites = UIImage(named: "favorites")
        
        static let dismiss = UIImage(named: "dismiss")
        static let menu = UIImage(named: "menu")
        static let search = UIImage(named: "search")
        static let favoriteEmpty = UIImage(named: "starEmpty")
        static let favoriteFilled = UIImage(named: "starFilled")
        
        static let playVideo = UIImage(named: "play")
    }
    
    class Font {
        
        enum Size: CGFloat {
            case title = 20
            case small = 8
            case medium = 12
        }
        
        static func system(size: Size) -> UIFont {
            return UIFont.systemFont(ofSize: size.rawValue)
        }
        
        static func nasalization(size: Size = .title) -> UIFont {
            return UIFont(name: "NasalizationRg-Regular", size: size.rawValue)!
        }
    }
    
    
    class Dimension {
        static let standardMargin: CGFloat = 8

    }
    
    class Color {
        static let primary = UIColor.white
        static let accent = UIColor.red
    }
    
}
