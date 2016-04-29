//
//  CoreDataMenuItem.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/29/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import CoreData


class CoreDataMenuItem: NSManagedObject {

// Insert code here to add functionality to your managed object subclass


    class func createInManagedObjectContext(moc: NSManagedObjectContext, name: String, course: String, mealTime: MealTime, diningHall: DiningHall) -> CoreDataMenuItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("CoreDataMenuItem", inManagedObjectContext: moc) as! CoreDataMenuItem
        newItem.name = name
        newItem.course = course
        newItem.diningHall = diningHall.intValue()
        newItem.mealTime = mealTime.intValue()

        return newItem
    }

    class func createInManagedObjectContext(moc: NSManagedObjectContext, menuItem: MenuItem) -> CoreDataMenuItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("CoreDataMenuItem", inManagedObjectContext: moc) as! CoreDataMenuItem
        newItem.name = menuItem.food
        newItem.course = menuItem.course
        newItem.diningHall = menuItem.diningHall.intValue()
        newItem.mealTime = menuItem.mealTime.intValue()

        return newItem
    }
    

}
