//
//  CoreDataMenuItem.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/29/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class CoreDataMenuItem: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    class func createInManagedObjectContext(moc: NSManagedObjectContext, menuItem: MenuItem) -> CoreDataMenuItem {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "CoreDataMenuItem", into: moc) as! CoreDataMenuItem
        newItem.name = menuItem.name
        newItem.course = menuItem.course
        newItem.diningHall = menuItem.diningHall.intValue()
        newItem.mealTime = menuItem.mealTime.intValue()
        // somehow, when setting isGlutenFree, we bounce.
//        newItem.isGlutenFree = menuItem.isGlutenFree
//        newItem.isVegan = menuItem.isVegan

        return newItem
    }
    

}
