//
//  CoreDataMenuItem+CoreDataProperties.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CoreDataMenuItem {
    
    @NSManaged var isVegan: Bool
    @NSManaged var isGlutenFree: Bool
    @NSManaged var name: String
    @NSManaged var mealTime: NSNumber
    @NSManaged var diningHall: NSNumber
    @NSManaged var course: String
}


