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

    class func createInManagedObjectContext(moc: NSManagedObjectContext, menuItem: MenuItem) -> CoreDataMenuItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("CoreDataMenuItem", inManagedObjectContext: moc) as! CoreDataMenuItem
        newItem.name = menuItem.name
        newItem.course = menuItem.course
        newItem.diningHall = menuItem.diningHall.intValue()
        newItem.mealTime = menuItem.mealTime.intValue()
        newItem.isGlutenFree = menuItem.isGlutenFree
        newItem.isVegan = menuItem.isVegan

        return newItem
    }
    

}
