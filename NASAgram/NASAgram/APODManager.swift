//
//  APODManager.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/12/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

class APODManager {
    let data: DataManager!
    let favorites: FavoritesManager!
    
    init(dataManager: DataManager, favoritesManager: FavoritesManager) {
        data = dataManager
        favorites = favoritesManager
    }
}
