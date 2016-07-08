//
//  MenuReade
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/**
MenuReader statically reads the menus in from Core Data memory.
 */
class MenuHandler: NSObject {

    private static let managedObjectContext = (UIApplication.shared().delegate as! AppDelegate).managedObjectContext

    private static let courseKey = "course"
    private static let mealTimeKey = "mealTime"
    private static let diningHallKey = "diningHall"
    private static let valueForKeyMatchesParameter = "%K == %@"

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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataMenuItem")
        let sortDescriptor = SortDescriptor(key: courseKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let firstPredicate = Predicate(format: valueForKeyMatchesParameter, diningHallKey, NSNumber(value: diningHall.intValue()))
        let secondPredicate = Predicate(format: valueForKeyMatchesParameter, mealTimeKey, NSNumber(value: mealTime.intValue()))

        fetchRequest.predicate = CompoundPredicate(type: .and, subpredicates: [firstPredicate,secondPredicate])

        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) as? [CoreDataMenuItem] {
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
     - mealTime: the MealTime according to which, to fetch the dining halls. If nil, fetch all dining halls that are accessible
     */
    internal static func fetchDiningHalls(mealTime: MealTime?) -> [DiningHall] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataMenuItem")
        if mealTime != nil {
            fetchRequest.predicate = Predicate(format: valueForKeyMatchesParameter, mealTimeKey, NSNumber(value: mealTime!.intValue()))
        }
        fetchRequest.propertiesToFetch = [diningHallKey]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType

        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) as? [[String:Int]] {
            return fetchResults!.map({DiningHall(num: $0[diningHallKey]!)})
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataMenuItem")
        if diningHall != nil {
            fetchRequest.predicate = Predicate(format: valueForKeyMatchesParameter, diningHallKey, NSNumber(value: diningHall!.intValue()))
        }
        fetchRequest.propertiesToFetch = [mealTimeKey]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType

        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) as? [[String:Int]] {
            return fetchResults!.map({MealTime(num: $0[mealTimeKey]!)})
        }
        return []
    }

    // MARK: favorites handling


    /**
     Insert a favorite food into the database
     */
    internal static func addItemToFavorites(name: String) {
        FavoritesHandler.addItemToFavorites(name: name)
    }

    /**
     Remove a favorite food from the database
     */
    internal static func removeItemFromFavorites(name: String) {
        FavoritesHandler.removeItemFromFavorites(name: name)
    }

    /**
     Returns whether the given food is a favorite or not. Constant time performance
     */
    internal static func isAFavoriteFood(name: String) -> Bool {
        return FavoritesHandler.isAFavoriteFood(name: name)
    }

    /**
     Fetch the user favorites as an array
     - returns: [String] of favorites
     */
    internal static func getFavorites() -> [String] {
        return FavoritesHandler.getFavorites()
    }
}
