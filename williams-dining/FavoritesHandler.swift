//
//  FavoritesHandler.swift
//  williams-dining
//
//  Created by Nathan Andersen on 5/1/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/**
 A class to manage the user's favorite foods in CoreData through abstraction
 */
class FavoritesHandler: NSObject {

    private static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    private static var favorites: Set<String>!
    private static var favoriteFoods: [FavoriteFood]!
    
    /**
     Insert a favorite food into the database
     */
    internal static func addItemToFavorites(name: String) {
        FavoriteFood.createInManagedObjectContext(managedObjectContext, name: name)
        do {
            try managedObjectContext.save()
        } catch {
            print("save failed")
        }
        updateFavorites()
    }

    /**
     Remove a favorite food from the database
     */
    internal static func removeItemFromFavorites(name: String) {
        var food: FavoriteFood!
        for favorite in favoriteFoods {
            if favorite.name == name {
                food = favorite
                break
            }
        }
        managedObjectContext.deleteObject(food)
        do {
            try managedObjectContext.save()
        } catch {
            print("save failed")
        }

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
        return favorites.sort()
    }

    /**
     Update the internal references for favorites
     */
    private static func updateFavorites() {
        favoriteFoods = fetchFavorites()
        favorites = Set<String>()
        favoriteFoods.forEach({favorites.insert($0.name!)})

        NSNotificationCenter.defaultCenter().postNotificationName("reloadFavoritesTable", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("reloadMealTable", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("reloadDiningHallTable", object: nil)

    }

    /**
     Fetch the user favorites from memory
     */
    private static func fetchFavorites() -> [FavoriteFood] {
        let fetchRequest = NSFetchRequest(entityName: "FavoriteFood")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [FavoriteFood] {

            return fetchResults!
        }
        return []
    }

}