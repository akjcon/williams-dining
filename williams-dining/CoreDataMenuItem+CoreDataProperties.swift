//
//  CoreDataMenuItem+CoreDataProperties.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/29/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import SwiftyJSON

extension CoreDataMenuItem {

    @NSManaged var name: String
    @NSManaged var mealTime: NSNumber
    @NSManaged var diningHall: NSNumber
    @NSManaged var course: String

}

struct MenuItem {
    var mealTime: MealTime
    var food: String
    var diningHall: DiningHall
    var course: String

    init() {
        self.mealTime = .Error
        food = ""
        diningHall = .Error
        course = ""
    }

    init(itemDict: JSON, diningHall: DiningHall) {
        self.mealTime = MealTime(mealTime: itemDict["meal"].string!)
        self.food = itemDict["formal_name"].string!
        self.diningHall = diningHall
        self.course = itemDict["course"].string!
    }
}
