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

    private static let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    private static let courseKey = "course"
    private static let mealTimeKey = "mealTime"
    private static let diningHallKey = "diningHall"
    private static let valueForKeyMatchesParameter = "%K == %@"


    public static func fetchByMealTimeAndDiningHall(mealTime: MealTime, diningHall: DiningHall) -> [CoreDataMenuItem] {
        return fetchByMealTimeAndDiningHall(mealTime: mealTime, diningHall: diningHall, moc: self.managedObjectContext)
    }

    public static func fetchByMealTimeAndDiningHall(mealTime: MealTime, diningHall: DiningHall, moc: NSManagedObjectContext) -> [CoreDataMenuItem] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataMenuItem")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: courseKey, ascending: true)]

        let diningHallPredicate = NSPredicate(format: valueForKeyMatchesParameter, diningHallKey, NSNumber(value: diningHall.intValue()))
        let mealTimePredicate = NSPredicate(format: valueForKeyMatchesParameter, mealTimeKey, NSNumber(value: mealTime.intValue()))

        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [diningHallPredicate,mealTimePredicate])

        if let fetchResults = try? moc.fetch(fetchRequest) as? [CoreDataMenuItem] {
            return fetchResults!
        }
        return []
    }

    public static func fetchDiningHalls(mealTime: MealTime?) -> [DiningHall] {
        return fetchDiningHalls(mealTime: mealTime, moc: self.managedObjectContext)
    }

    public static func fetchDiningHalls(mealTime: MealTime?, moc: NSManagedObjectContext) -> [DiningHall] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataMenuItem")
        if mealTime != nil {
            fetchRequest.predicate = NSPredicate(format: valueForKeyMatchesParameter, mealTimeKey, NSNumber(value: mealTime!.intValue()))
        }
        fetchRequest.propertiesToFetch = [diningHallKey]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType

        if let fetchResults = try? moc.fetch(fetchRequest) as? [[String:Int]] {
            return fetchResults!.map({
                DiningHall(num: NSNumber(integerLiteral: $0[diningHallKey]!))
            })
        }
        return []
    }

    public static func fetchMealTimes(diningHall: DiningHall?) -> [MealTime] {
        return fetchMealTimes(diningHall: diningHall, moc: self.managedObjectContext)
    }

    public static func fetchMealTimes(diningHall: DiningHall?, moc: NSManagedObjectContext) -> [MealTime] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataMenuItem")
        if diningHall != nil {
            fetchRequest.predicate = NSPredicate(format: valueForKeyMatchesParameter, diningHallKey, NSNumber(integerLiteral: diningHall!.intValue()))
        }
        fetchRequest.propertiesToFetch = [mealTimeKey]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType

        if let fetchResults = try? moc.fetch(fetchRequest) as? [[String:Int]] {
            return fetchResults!.map({
                MealTime(num: NSNumber(integerLiteral: $0[mealTimeKey]!))
            }).sorted(by: {
                (a,b) in (a.intValue() < b.intValue())})
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
    internal static func parseMenu(menu: AnyObject, diningHall: DiningHall, favoritesNotifier: FavoritesNotifier, completionHandler: @escaping () -> ()) {
        let individualCompletion: (MenuItem) -> () = {
            (item: MenuItem) in

            if FavoritesHandler.isAFavoriteFood(name: item.name) {
                favoritesNotifier.addToFavoritesList(item: item)
            }
        }
        parseMenu(menu: menu, diningHall: diningHall, individualCompletion: individualCompletion, completionHandler: completionHandler, moc: self.managedObjectContext)
    }

    internal static func parseMenu(menu: AnyObject, diningHall: DiningHall, individualCompletion: ((MenuItem) -> ())?, completionHandler: (() -> ())?, moc: NSManagedObjectContext ) {
        let completionFn = {
            (item: MenuItem) in
            _ = CoreDataMenuItem.createInManagedObjectContext(moc: moc, menuItem: item)
            if let indComp = individualCompletion {
                indComp(item)
            }
        }
        parseMenu(menu: menu, diningHall: diningHall, individualCompletion: completionFn, completionHandler: completionHandler)
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
