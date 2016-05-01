//
//  MenuReade
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/**
MenuReader statically reads the menus in from Core Data memory.
 */
class MenuHandler: NSObject {

    private static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    /**
     Fetch all menu items for a given diningHall and a given mealTime
     
     - parameters:
        - diningHall: the selected diningHall
        - mealTime: the selected mealTime
     
     SELECT *
     FROM CoreData
     WHERE  diningHall = diningHall
        AND mealTime = mealTime
    */
    internal static func fetchByMealTimeAndDiningHall(mealTime: MealTime, diningHall: DiningHall) -> [CoreDataMenuItem] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        let sortDescriptor = NSSortDescriptor(key: "course", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let firstPredicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall.intValue()))
        let secondPredicate = NSPredicate(format: "%K == %@", "mealTime", NSNumber(integer: mealTime.intValue()))

        fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [firstPredicate,secondPredicate])

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            return fetchResults!
        }
        return []
    }


    /**
     Fetch all active dining halls of the mealTime (optional)

     SELECT UNIQUE diningHall
     FROM CoreData
     WHERE mealTime = mealTime (optional)

     - parameters:
     - mealTime: the MealTime according to which, to fetch the dining halls
     */
    internal static func fetchDiningHalls(mealTime: MealTime?) -> [DiningHall] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        if mealTime != nil {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", "mealTime", NSNumber(integer: mealTime!.intValue()))
        }

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            var diningHalls = Set<DiningHall>()
            fetchResults!.forEach({
                diningHalls.insert(DiningHall(num: $0.diningHall))
            })
            return Array(diningHalls).sort({$0.intValue() < $1.intValue() })
        }
        return []
    }

    /**
     Fetch all active meal times from Core Data
    - parameters: 
        - diningHall: the optional dining hall

     SELECT UNIQUE mealTime
     FROM CoreData
     WHERE diningHall = diningHall (optional)
     */
    internal static func fetchMealTimes(diningHall: DiningHall?) -> [MealTime] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        if diningHall != nil {
            fetchRequest.predicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall!.intValue()))
        }
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {

            var mealTimes = Set<MealTime>()
            fetchResults!.forEach({
                mealTimes.insert(MealTime(num: $0.mealTime))
            })
            return Array(mealTimes).sort({$0.intValue() < $1.intValue() })
        }
        return []
    }

    // MARK: favorites handling


    /**
     Insert a favorite food into the database
     */
    internal static func addItemToFavorites(name: String) {
        FavoritesHandler.addItemToFavorites(name)
    }

    /**
     Remove a favorite food from the database
     */
    internal static func removeItemFromFavorites(name: String) {
        FavoritesHandler.removeItemFromFavorites(name)
    }

    /**
     Returns whether the given food is a favorite or not. Constant time performance
     */
    internal static func isAFavoriteFood(name: String) -> Bool {
        return FavoritesHandler.isAFavoriteFood(name)
    }

    /**
     Fetch the user favorites as an array
     - returns: [String] of favorites
     */
    internal static func getFavorites() -> [String] {
        return FavoritesHandler.getFavorites()
    }
}
