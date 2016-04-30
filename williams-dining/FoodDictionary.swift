//
//  FoodDictionary.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

var foodDictionary: FoodDictionary!

class FoodDictionary: NSObject {


    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

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
        if predicate != nil {
            fetchRequest.predicate = predicate!
        }

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {

//            print(fetchResults)
            var diningHalls = Set<DiningHall>()
            fetchResults!.forEach({
                diningHalls.insert(DiningHall(num: $0.diningHall))
            })
//            print(diningHalls)
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

/*    override init() {
        super.init()
    }*/


    }
