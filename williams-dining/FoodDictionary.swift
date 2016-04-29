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

    var time: NSDate?

    func fetch(completion: () -> Void) {
        time = NSDate()
        completion()
    }

    




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
    internal func fetchByMealTimeAndDiningHall(mealTime: MealTime, diningHall: DiningHall) -> [CoreDataMenuItem] {
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
     Fetch all active dining halls from Core Data
     
     SELECT UNIQUE diningHall
     FROM CoreData
    */
    internal func fetchActiveDiningHalls() -> [DiningHall] {
        return fetchActiveDiningHalls(nil)
    }

    /**
     Fetch active meal times for a given dining hall

     - parameters:
     - diningHall: the selected diningHall

     SELECT UNIQUE mealTime
     FROM CoreData
     WHERE diningHall = diningHall
     */
    internal func fetchMealTimesForDiningHall(diningHall: DiningHall) -> [MealTime] {
        let predicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall.intValue()))
        return fetchActiveMealTimes(predicate)
    }

    /**
     Fetch all active dining halls according to the predicate
     
     SELECT UNIQUE diningHall
     FROM CoreData
     WHERE predicate

     - parameters: 
        - predicate: the NSPredicate according to which, to fetch the dining halls
    */
    private func fetchActiveDiningHalls(predicate: NSPredicate?) -> [DiningHall] {
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
    internal func fetchActiveMealTimes() -> [MealTime] {
        return fetchActiveMealTimes(nil)
    }



    /**
     Fetch active meal times for a given dining hall

     - parameters:
     - diningHall: the selected diningHall

     SELECT UNIQUE mealTime
     FROM CoreData
     WHERE predicate
     */
    private func fetchActiveMealTimes(predicate: NSPredicate?) -> [MealTime] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        if predicate != nil {
            fetchRequest.predicate = predicate!
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

    /**
     Fetch active dining halls for a given meal time

     - parameters:
     - mealTime: the selected MealTime

     SELECT UNIQUE diningHall
     FROM CoreData
     WHERE mealTime = mealTime
     */
    internal func fetchDiningHallsForMealTime (mealTime: MealTime) -> [DiningHall] {
        let predicate = NSPredicate(format: "%K == %@", "mealTime", NSNumber(integer: mealTime.intValue()))
        return fetchActiveDiningHalls(predicate)
    }

    /*
    override init() {
        super.init()

        // temporarily here, but later will move this to auto-update or something
        self.loadAPIMenusIntoMemory()

        // load menus into app from CoreData (?)
    }*/


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
    internal func fetchMenusFromAPI() {
        menuCounter = 5
        let sc = NSPersistentStoreCoordinator()
        let stores = sc.persistentStores
//        NSArray *stores = [persistentStoreCoordinator persistentStores];
        for store in stores {
            try? sc.removePersistentStore(store)
            try? NSFileManager.defaultManager().removeItemAtPath((store.URL?.path)!)
        }


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
}
