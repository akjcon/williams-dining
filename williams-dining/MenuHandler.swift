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
        fetchRequest.sortDescriptors = [SortDescriptor(key: courseKey, ascending: true)]

        let diningHallPredicate = Predicate(format: valueForKeyMatchesParameter, diningHallKey, NSNumber(value: diningHall.intValue()))
        let mealTimePredicate = Predicate(format: valueForKeyMatchesParameter, mealTimeKey, NSNumber(value: mealTime.intValue()))

        fetchRequest.predicate = CompoundPredicate(type: .and, subpredicates: [diningHallPredicate,mealTimePredicate])

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


    /**
     Clears the data stored in CoreData for new menu-space.
     */
    internal static func clearCachedData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataMenuItem")
        fetchRequest.includesPropertyValues = false
        if let fetchResults = try? managedObjectContext.fetch(fetchRequest) as? [CoreDataMenuItem] {
            for item in fetchResults! {
                managedObjectContext.delete(item)
            }
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("While clearing the menus, the save failed")
        }
    }


    /**
     This method parses the JSON returned from the API and inserts it into CoreData

     - parameters:
     - jsonMenu: a JSON object with the menu information
     - diningHall: the DiningHall enum that the menu corresponds to
     - favoritesNotifier: the FavoritesNotifier that will handle notifications
     - completionHandler: a function to call at completion
     */
    internal static func parseMenu(menu: AnyObject, diningHall: DiningHall, favoritesNotifier: FavoritesNotifier, completionHandler: () -> ()) {
        if let menuItems: [[String:AnyObject]] = menu as? [[String:AnyObject]] {
            for itemDict in menuItems {
                let menuItem = MenuItem(itemDict: itemDict, diningHall: diningHall)
                _ = CoreDataMenuItem.createInManagedObjectContext(moc: managedObjectContext, menuItem: menuItem)
                if FavoritesHandler.isAFavoriteFood(name: menuItem.name) {
                    favoritesNotifier.addToFavoritesList(item: menuItem)
                }
            }
            completionHandler()
        } else {
            print("Error in menu parsing. Here is the menu")
            print(menu)
        }
    }
}
