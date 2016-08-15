//
//  MockMenuCache.swift
//  williams-dining
//
//  Created by Nathan Andersen on 8/15/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import CoreData

class MockMenuCache {

    static var moc: NSManagedObjectContext!

    /*
     This will define where we look for our test data.
     */
    static let diningHallJSONDict: [DiningHall:String] = [
        DiningHall.Whitmans: "Whitmans",
        DiningHall.EcoCafe: "EcoCafe",
        DiningHall.GrabAndGo: "GrabAndGo"
    ]

    static func setupMockManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main()])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Initializing in-memory persistent store failed")
        }
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        moc = managedObjectContext
        return managedObjectContext
    }

    static func initializeMockData() {
        // insert some data

        for item in diningHallJSONDict {
            if let path = Bundle.main().pathForResource(item.value, ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.dataReadingMappedIfSafe)
                    if let jsonResult: AnyObject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) {
                        if let menuItems: [[String:AnyObject]] = jsonResult as? [[String:AnyObject]] {
                            for itemDict in menuItems {
                                let menuItem = MenuItem(itemDict: itemDict, diningHall: item.key)
                                _ = CoreDataMenuItem.createInManagedObjectContext(moc: moc, menuItem: menuItem)
                            }
                            print("wow ok")
                            print(item.key)
                        } else {
                            print("Error in menu parsing. Here is the menu")
                        }
                    }
                    // finish this up
                } catch let error as NSError {
                    print(error.localizedDescription)
                } catch {
                    print("uh oh")
                }
            } else {
                print("invalid filename / path")
            }
        }
        
    }
}
