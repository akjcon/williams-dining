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
public class MenuHandler: MenuHandlerProtocol {

    // this is a var for Unit Testing

/*    public static var managedObjectContext: NSManagedObjectContext {
        get {

        }
        set {

        }
    }*/

    private static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    private static let courseKey = "course"
    private static let mealTimeKey = "mealTime"
    private static let diningHallKey = "diningHall"
    private static let valueForKeyMatchesParameter = "%K == %@"


    public static func fetchByMealTimeAndDiningHall(mealTime: MealTime, diningHall: DiningHall) -> [CoreDataMenuItem] {
        return fetchByMealTimeAndDiningHall(mealTime, diningHall: diningHall, moc: self.managedObjectContext)
    }

    public static func fetchByMealTimeAndDiningHall(mealTime: MealTime, diningHall: DiningHall, moc: NSManagedObjectContext) -> [CoreDataMenuItem] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: courseKey, ascending: true)]

        let diningHallPredicate = NSPredicate(format: valueForKeyMatchesParameter, diningHallKey, NSNumber(integer: diningHall.intValue()))
        let mealTimePredicate = NSPredicate(format: valueForKeyMatchesParameter, mealTimeKey, NSNumber(integer: mealTime.intValue()))

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [diningHallPredicate,mealTimePredicate])
//        fetchRequest.predicate = NSCompoundPredicate(type: .And, subpredicates: [diningHallPredicate,mealTimePredicate])

        if let fetchResults = try? moc.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            return fetchResults!
        }
        return []
    }

    public static func fetchDiningHalls(mealTime: MealTime?) -> [DiningHall] {
        return fetchDiningHalls(mealTime, moc: self.managedObjectContext)
    }

    public static func fetchDiningHalls(mealTime: MealTime?, moc: NSManagedObjectContext) -> [DiningHall] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        if mealTime != nil {
            fetchRequest.predicate = NSPredicate(format: valueForKeyMatchesParameter, mealTimeKey, NSNumber(integer: mealTime!.intValue()))
        }
        fetchRequest.propertiesToFetch = [diningHallKey]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType

        if let fetchResults = try? moc.executeFetchRequest(fetchRequest) as? [[String:Int]] {
            return fetchResults!.map({DiningHall(num: $0[diningHallKey]!)})
        }
        return []
    }

    public static func fetchMealTimes(diningHall: DiningHall?) -> [MealTime] {
        return fetchMealTimes(diningHall, moc: self.managedObjectContext)
    }

    public static func fetchMealTimes(diningHall: DiningHall?, moc: NSManagedObjectContext) -> [MealTime] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        if diningHall != nil {
            fetchRequest.predicate = NSPredicate(format: valueForKeyMatchesParameter, diningHallKey, NSNumber(integer: diningHall!.intValue()))
        }
        fetchRequest.propertiesToFetch = [mealTimeKey]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType

        if let fetchResults = try? moc.executeFetchRequest(fetchRequest) as? [[String:Int]] {
            return fetchResults!
                .map({MealTime(num: $0[mealTimeKey]!)})
                .sort({(a,b) in (a.intValue() < b.intValue())})
//            return fetchResults!.map({MealTime(num: $0[mealTimeKey]!)}).sorted({(a,b) in (a.intValue() < b.intValue())})
        }
        return []
    }

    /**
     Clears the data stored in CoreData for new menu-space.
     */
    internal static func clearCachedData() {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        fetchRequest.includesPropertyValues = false
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            for item in fetchResults! {
                managedObjectContext.deleteObject(item)
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
        let individualCompletion: (MenuItem) -> () = {
            (item: MenuItem) in

            if FavoritesHandler.isAFavoriteFood(item.name) {
                favoritesNotifier.addToFavoritesList(item)
            }
        }
        parseMenu(menu, diningHall: diningHall, individualCompletion: individualCompletion, completionHandler: completionHandler, moc: self.managedObjectContext)
    }

    internal static func parseMenu(menu: AnyObject, diningHall: DiningHall, individualCompletion: ((MenuItem) -> ())?, completionHandler: (() -> ())?, moc: NSManagedObjectContext ) {
        let completionFn = {
            (item: MenuItem) in
            _ = CoreDataMenuItem.createInManagedObjectContext(moc, menuItem: item)
            if let indComp = individualCompletion {
                indComp(item)
            }
        }
        parseMenu(menu, diningHall: diningHall, individualCompletion: completionFn, completionHandler: completionHandler)
        /*        if let menuItems: [[String:AnyObject]] = menu as? [[String:AnyObject]] {
            for itemDict in menuItems {
                let menuItem = MenuItem(itemDict: itemDict, diningHall: diningHall)
                _ = CoreDataMenuItem.createInManagedObjectContext(moc: moc, menuItem: menuItem)
                if let indComp = individualCompletion {
                    indComp(menuItem)
                }
            }
            if let comp = completionHandler {
                comp()
            }
        } else {
            print("Error in menu parsing. Here is the menu")
            print(menu)
        }*/
    }

    internal static func parseMenu(menu: AnyObject, diningHall: DiningHall, individualCompletion: ((MenuItem) -> ())?, completionHandler: (() -> ())?) {
        if let menuItems: [[String:AnyObject]] = menu as? [[String:AnyObject]] {
            for itemDict in menuItems {
                let menuItem = MenuItem(itemDict: itemDict, diningHall: diningHall)
                if let indComp = individualCompletion {
                    indComp(menuItem)
                }
            }
            if let comp = completionHandler {
                comp()
            }
        } else {
            print("Error in menu parsing. Here is the menu")
            print(menu)
        }
    }
}
