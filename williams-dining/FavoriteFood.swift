//
//  FavoriteFood.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import CoreData


class FavoriteFood: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    class func createInManagedObjectContext(moc: NSManagedObjectContext, name: String) -> FavoriteFood {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "FavoriteFood", into: moc) as! FavoriteFood
        newItem.name = name
        return newItem
    }
}
