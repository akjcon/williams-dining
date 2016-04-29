//
//  FoodDictionary.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

import CoreData

var foodDictionary: FoodDictionary!

class FoodDictionary: NSObject {

    /**
     TODO
     
     
     I have implemented all methods for fetching from mem
     
     so.. at initialization, fetch from mem
     
     then just call for local variable get/sets
 
     
     at some other point, call for core data refresh
 
    */

    




    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

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
    func fetchByMealTimeAndDiningHall(mealTime: MealTime, diningHall: DiningHall) -> [CoreDataMenuItem] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")

        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "course", ascending: true)

        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]

        let firstPredicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall.intValue()))
        let secondPredicate = NSPredicate(format: "%K == %@", "mealTime", NSNumber(integer: mealTime.intValue()))


        // Set the predicate on the fetch request
        fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [firstPredicate,secondPredicate])

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {

            return fetchResults!
        }
        return []

    }

    /**
     Fetch all active dining halls from Core Data
     
     SELECT UNIQUE diningHall
     FROM CoreData
    */
    func fetchActiveDiningHalls() -> [DiningHall] {
        return fetchActiveDiningHalls(nil)
        /*
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            var diningHalls = Set<DiningHall>()
            fetchResults!.forEach({
                diningHalls.insert(DiningHall(num: $0.diningHall))
            })
            return Array(diningHalls).sort({$0.intValue() < $1.intValue() })
        }
        return []*/
    }

    /**
     Fetch all active dining halls according to the predicate
     
     SELECT UNIQUE diningHall
     FROM CoreData
     WHERE predicate

     - parameters: 
        - predicate: the NSPredicate according to which, to fetch the dining halls
    */
    func fetchActiveDiningHalls(predicate: NSPredicate?) -> [DiningHall] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")

        // consider a sort descriptor?

        if predicate != nil {
            fetchRequest.predicate = predicate!
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

     SELECT UNIQUE mealTime
     FROM CoreData
     */
    func fetchActiveMealTimes() -> [MealTime] {
        return fetchActiveMealTimes(nil)
/*        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            var mealTimes = Set<MealTime>()
            fetchResults!.forEach({
                mealTimes.insert(MealTime(num: $0.mealTime))
            })
            return Array(mealTimes).sort({$0.intValue() < $1.intValue() })
        }
        return []*/
    }

    /**
     Fetch active meal times for a given dining hall
     
     - parameters:
        - diningHall: the selected diningHall
     
     SELECT UNIQUE mealTime
     FROM CoreData
     WHERE diningHall = diningHall
    */
    func fetchMealTimesForDiningHall(diningHall: DiningHall) -> [MealTime] {
//        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")

        // consider a sort descriptor?

        let predicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall.intValue()))

//        fetchRequest.predicate = predicate

        return fetchActiveMealTimes(predicate)

/*        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {

            var mealTimes = Set<MealTime>()
            fetchResults!.forEach({
                mealTimes.insert(MealTime(num: $0.mealTime))
            })
            return Array(mealTimes).sort({$0.intValue() < $1.intValue() })
        }
        return []*/
    }

    /**
     Fetch active meal times for a given dining hall

     - parameters:
     - diningHall: the selected diningHall

     SELECT UNIQUE mealTime
     FROM CoreData
     WHERE predicate
     */
    func fetchActiveMealTimes(predicate: NSPredicate?) -> [MealTime] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")

        // consider a sort descriptor?

        if predicate != nil {
            fetchRequest.predicate = predicate!
        }

//        let predicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall.intValue()))
//        fetchRequest.predicate = predicate

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {

            var mealTimes = Set<MealTime>()
            fetchResults!.forEach({
                mealTimes.insert(MealTime(num: $0.mealTime))
            })
            return Array(mealTimes).sort({$0.intValue() < $1.intValue() })
        }
        return []
    }

    /**
     Fetch active dining halls for a given meal time

     - parameters:
     - mealTime: the selected MealTime

     SELECT UNIQUE diningHall
     FROM CoreData
     WHERE mealTime = mealTime
     */
    func fetchDiningHallsForMealTime (mealTime: MealTime) -> [DiningHall] {

//        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")

        // consider a sort descriptor?

        let predicate = NSPredicate(format: "%K == %@", "mealTime", NSNumber(integer: mealTime.intValue()))

        return fetchActiveDiningHalls(predicate)
/*        fetchRequest.predicate = predicate

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {

            var diningHalls = Set<DiningHall>()
            fetchResults!.forEach({
                diningHalls.insert(DiningHall(num: $0.diningHall))
            })
            return Array(diningHalls).sort({$0.intValue() < $1.intValue() })
        }
        return []*/
    }


    /*
    func fetchDiningHallItems(diningHall: DiningHall) -> [CoreDataMenuItem] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")

        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "course", ascending: true)

        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]

        let predicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall.intValue()))


        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            return fetchResults!
        }
        return []
    }*/

    override init() {
        super.init()

        // temporarily here, but later will move this to auto-update or something
        self.fetchMenus()

        // load menus into app from CoreData (?)
    }


    /**
     There are 5 dining halls
    */
    private var menuCounter = 5

    /**
     Each time a menu is loaded into memory, decrement the counter.
     When we have loaded all menus, tell the app that the data is ready.
    */
    private func decrementMenuCounter() {
        menuCounter -= 1
        print(menuCounter)

        if menuCounter == 0 {
            NSNotificationCenter.defaultCenter().postNotificationName("dataIsReady", object: nil)
        }
    }

    /**
     This queries the API, one dining hall at a time, loading the results into CoreData in memory.
     
     This should only be called once a day
    */
    private func fetchMenus() {
        for diningHall in DiningHall.allCases {
            self.getMenu(diningHall)
        }
    }

    /**
     This method queries the API for a given dining hall
     - parameters:
        - diningHall: the given dining hall
    */
    private func getMenu(diningHall: DiningHall) {
        Alamofire.request(.GET, "https://dining.williams.edu/wp-json/dining/service_units/" + String(diningHall.getAPIValue())).responseJSON { (response) in
            guard response.result.error == nil else {
                print("Error occurred during menu request")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                self.parseMenu(JSON(value), diningHall: diningHall)
            }
        }
    }

    /**
     This method parses the JSON returned from the API and inserts it into CoreData
     
     - parameters:
        - jsonMenu: a JSON object with the menu information
        - diningHall: the DiningHall enum that the menu corresponds to
    */
    private func parseMenu(jsonMenu: JSON, diningHall: DiningHall) {
        let moc = self.managedObjectContext
        for (_,itemDictionary):(String,JSON) in jsonMenu {
            CoreDataMenuItem.createInManagedObjectContext(moc, menuItem: MenuItem(itemDict: itemDictionary, diningHall: diningHall))
        }
        self.decrementMenuCounter()
    }

    /*

    private var activeMealTimes = [MealTime]()

    private var activeDiningHalls = [DiningHall]()

    private var mealTimesForDiningHalls = [DiningHall:[MealTime]]()
    // Dining Halls -> Meal Times (keys for diningHallMenus)
    private var diningHallMenus = [DiningHall:[MealTime:[MenuItem]]]()
    // Dining Halls -> Meal Times -> Menu Items

    private var mealMenus = [MealTime:[DiningHall:[MenuItem]]]()
    // Meal Times -> Dining Halls -> Menu Items
    private var diningHallsForMealTimes = [MealTime:[DiningHall]]()
    // Meal Times -> Dining Halls (keys for mealMenus)

    func getActiveMealTimes() -> [MealTime] {
        return activeMealTimes.sort({$0.intValue() < $1.intValue() })
    }

    func getActiveDiningHalls() -> [DiningHall] {
        return activeDiningHalls.sort({$0.intValue() < $1.intValue() })
    }


    func getMealTimesForDiningHall(diningHall: DiningHall) -> [MealTime]? {
        let mealTimes = mealTimesForDiningHalls[diningHall]
        if mealTimes == nil {
            return []
        } else {
            return mealTimes!.sort({$0.intValue() < $1.intValue() })
        }
    }

    func getDiningHallsForMealTime(mealTime: MealTime) -> [DiningHall]? {
        let diningHalls = diningHallsForMealTimes[mealTime]
        if diningHalls == nil {
            return []
        } else {
            return diningHalls!.sort({$0.intValue() < $1.intValue() })
        }
    }


    func getDiningHallMenu(diningHall: DiningHall) -> [MealTime:[MenuItem]]? {
        return diningHallMenus[diningHall]
    }

    func getMealMenu(mealTime: MealTime) -> [DiningHall:[MenuItem]]? {
        return mealMenus[mealTime]
    }*/

    /*
    func addItemToDiningHallDict(item: MenuItem) {
        // add it to dict of keys
        var mealKeys = mealTimesForDiningHalls[item.diningHall]
        if mealKeys == nil {
            mealKeys = [item.mealTime]
        } else {
            if !mealKeys!.contains(item.mealTime) {
                mealKeys!.append(item.mealTime)
            }
        }
        mealTimesForDiningHalls[item.diningHall] = mealKeys


        // add it to the dict of dicts
        var diningHallDict = diningHallMenus[item.diningHall]
        if diningHallDict == nil {
            diningHallDict = [item.mealTime:[item]]
        } else {
            var mealDict = diningHallDict![item.mealTime]
            if mealDict == nil {
                mealDict = [item]
            } else {
                mealDict?.append(item)
            }
            diningHallDict![item.mealTime] = mealDict
        }
        diningHallMenus[item.diningHall] = diningHallDict

    }

    func addItemToMealDict(item: MenuItem) {
        // add it to dict of keys
        var diningHallKeys = diningHallsForMealTimes[item.mealTime]
        if diningHallKeys == nil {
            diningHallKeys = [item.diningHall]
        } else {
            if !diningHallKeys!.contains(item.diningHall) {
                diningHallKeys!.append(item.diningHall)
            }
        }
        diningHallsForMealTimes[item.mealTime] = diningHallKeys


        // add to dict of dicts
        var mealDict = mealMenus[item.mealTime]
        if mealDict == nil {
            mealDict = [item.diningHall:[item]]
        } else {
            var diningHallDict = mealDict![item.diningHall]
            if diningHallDict == nil {
                diningHallDict = [item]
            } else {
                diningHallDict?.append(item)
            }
            mealDict![item.diningHall] = diningHallDict
        }
        mealMenus[item.mealTime] = mealDict
    }*/

    /*
    func addMenuItem(item: MenuItem) {
        if !activeMealTimes.contains(item.mealTime) {
            activeMealTimes.append(item.mealTime)
        }

        if !activeDiningHalls.contains(item.diningHall) {
            activeDiningHalls.append(item.diningHall)
        }


        addItemToDiningHallDict(item)
        addItemToMealDict(item)
    }*/
}
