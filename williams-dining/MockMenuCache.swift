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

    static var mockManagedObjectContext: NSManagedObjectContext = {
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        } catch {
            print("Initializing in-memory persistent store failed")
        }
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        moc = managedObjectContext
        return managedObjectContext
    }()

    static func initializeMockData(/*callback: () -> ()*/) {
        // insert some data

        for item in diningHallJSONDict {
            if let path = NSBundle.mainBundle().pathForResource(item.1, ofType: "json") {
                do {
                    let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if let jsonResult: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) {
                        MenuHandler.parseMenu(jsonResult, diningHall: item.0, individualCompletion: nil, completionHandler: nil, moc: mockManagedObjectContext)
                        //print(item.key)
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
