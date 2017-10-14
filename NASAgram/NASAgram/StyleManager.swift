//
//  StyleManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 9/28/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

struct StyleManager {
    
    struct Text {
        static let appTitle = "ASTROdaily"
        static let videoPlayExplanation = "open video in browser?"
        static let copyrightPrefix = "© "
        static let dailyTitle = "Daily"
        static let favoritesTitle = "Favorites"
        static let done = "Done"
        static let emptyStateText = "No Photos Saved to Favorites"
    }
    
    struct Icon {
        
        static let daily = UIImage(named: "daily")
        static let favorites = UIImage(named: "favorites")
        
        static let dismiss = UIImage(named: "dismiss")
        static let menu = UIImage(named: "menu")
        static let search = UIImage(named: "search")
        static let favoriteEmpty = UIImage(named: "starEmpty")
        static let favoriteFilled = UIImage(named: "starFilled")
        
        static let playVideo = UIImage(named: "play")
    }
    
    struct Image {
        static let background = UIImage(named: "APODBackgroundImage")
    }
    
    struct Font {
        enum Size: CGFloat {
            case small = 8
            case medium = 14
            case large = 18
            case title = 20
            case extraLarge = 80
        }
        
        static func system(size: Size) -> UIFont {
            return UIFont.systemFont(ofSize: size.rawValue)
        }
        
        static func nasalization(size: Size = .title) -> UIFont {
            return UIFont(name: "NasalizationRg-Regular", size: size.rawValue)!
        }
    }
    
    
    struct Dimension {
        static let standardMargin: CGFloat = 8
        static let detailWidthMultiplier: CGFloat = 0.9
        static let dateViewHeight: CGFloat = 40
        static let toolBarViewHeight: CGFloat = 50.0
        static let activityIndicatorSize: CGFloat = 100
    }
    
    struct Animation {
        static let fadeDuration = 0.2
        static let slideDuration = 0.2
    }
    
    struct Color {
        static let primary = UIColor.white
        static let accent = UIColor(hexString: "#7d26cf")
        static let accentLight = UIColor(hexString: "#d2b1f1")
    }
    
}
