//
//  MenuHandlerProtocol.swift
//  williams-dining
//
//  Created by Nathan Andersen on 8/15/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation

public protocol MenuHandlerProtocol {

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
    static func fetchByMealTimeAndDiningHall(mealTime: MealTime, diningHall: DiningHall) -> [CoreDataMenuItem]
    
    /**
     Fetch all active dining halls of the mealTime (optional)

     SELECT UNIQUE diningHall
     FROM CoreData
     WHERE mealTime = mealTime (optional)

     - parameters:
     - mealTime: the MealTime according to which, to fetch the dining halls. If nil, fetch all dining halls that are accessible
     */
    static func fetchDiningHalls(mealTime: MealTime?) -> [DiningHall]

    /**
     Fetch all active meal times from Core Data
     - parameters:
     - diningHall: the optional dining hall

     SELECT UNIQUE mealTime
     FROM CoreData
     WHERE diningHall = diningHall (optional)
     */
    static func fetchMealTimes(diningHall: DiningHall?) -> [MealTime]
}
