//
//  FavoritesHandler.swift
//  williams-dining
//
//  Created by Nathan Andersen on 5/1/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import CoreData
import UIKit


let reloadFavoritesTableKey: NSNotification.Name = NSNotification.Name("reloadFavoritesTable")
let reloadMealTableViewKey = NSNotification.Name("reloadMealTableView")
let reloadDiningHallTableViewKey = NSNotification.Name("reloadDiningHallTableView")


/**
 This class implements local caching and fetching of user Favorites.
 */
public class FavoritesHandler {

    private static let appDelegate = UIApplication.shared().delegate as! AppDelegate
    private static var favorites: Set<String>!
    private static var favoriteFoods: [FavoriteFood]!
    
    /**
     Insert a favorite food into the database
     */
    internal static func addItemToFavorites(name: String) {
        _ = FavoriteFood.createInManagedObjectContext(moc: appDelegate.managedObjectContext, name: name)
        appDelegate.saveContext()
        updateFavorites()
    }

    /**
     Remove a favorite food from the database
     */
    internal static func removeItemFromFavorites(name: String) {
        var food: FavoriteFood?
        for favorite in favoriteFoods {
            if favorite.name == name {
                food = favorite
                break
            }
        }
        guard let favFood = food else {
            return
        }
        appDelegate.managedObjectContext.delete(favFood)
        appDelegate.saveContext()
        updateFavorites()
    }

    /**
     Returns whether the given food is a favorite or not. Constant time performance
     */
    internal static func isAFavoriteFood(name: String) -> Bool {
        if favorites == nil {
            updateFavorites()
        }
        return favorites.contains(name)
    }

    /**
     Fetch the user favorites as an array
     - returns: [String] of favorites
     */
    internal static func getFavorites() -> [String] {
        if favorites == nil {
            updateFavorites()
        }
        var favs: [String] = []
        for f in favorites {
            favs.append(f)
        }
        return favs.sorted()
    }

    /**
     Update the internal references for favorites
     */
    private static func updateFavorites() {
        favoriteFoods = fetchFavorites()
        favorites = Set<String>()
        favoriteFoods.forEach({favorites.insert($0.name!)})

        NotificationCenter.default().post(name: reloadFavoritesTableKey, object: nil)
        NotificationCenter.default().post(name: reloadMealTableViewKey, object: nil)
        NotificationCenter.default().post(name: reloadDiningHallTableViewKey, object: nil)
    }

    /**
     Fetch the user favorites from memory
     */
    private static func fetchFavorites() -> [FavoriteFood] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteFood")
        let sortDescriptor = SortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let fetchResults = try? appDelegate.managedObjectContext.fetch(fetchRequest) as? [FavoriteFood] {

            return fetchResults!
        }
        return []
    }

}
