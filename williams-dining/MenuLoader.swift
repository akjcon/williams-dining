//
//  MenuLoader.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwiftyJSON
import Alamofire

/**
 This class queries the API for the JSON menus, then loads them into CoreData memory.
 */
class MenuLoader: NSObject {

    private static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    /*
    /**
     There are 5 dining halls
     */
    private static var menuCounter = 5

    /**
     Each time a menu is loaded into memory, decrement the counter.
     When we have loaded all menus, tell the app that the data is ready.
     */
    private static func decrementMenuCounter() {
        menuCounter -= 1
        print(menuCounter)

        if menuCounter == 0 {
            (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
//            NSNotificationCenter.defaultCenter().postNotificationName("dataIsReady", object: nil)
        }
    }*/

    /**
     This queries the API, one dining hall at a time, loading the results into
     CoreData in memory.
     
     - returns: the status of the Data
 
    */
    internal static func fetchMenusFromAPI(completionHandler: (UIBackgroundFetchResult) -> Void) {
        var menusRemaining = 5
        self.wipeStores()

        func completion() {
            menusRemaining -= 1
            print(menusRemaining)
            if menusRemaining == 0 {
                completionHandler(.NewData)
                (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
            }
        }

        for diningHall in DiningHall.allCases {
            self.getMenu(diningHall) {
                completion()
            }
        }
    }

    /**
     This method queries the API for a given dining hall
     - parameters:
     - diningHall: the given dining hall
     */
    private static func getMenu(diningHall: DiningHall, completionHandler: () -> ()) {
        Alamofire.request(.GET, "https://dining.williams.edu/wp-json/dining/service_units/" + String(diningHall.getAPIValue())).responseJSON { (response) in
            guard response.result.error == nil else {
                print("Error occurred during menu request")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                self.parseMenu(JSON(value), diningHall: diningHall) {
                    completionHandler()
                }
            }
        }
    }

    /**
     This method parses the JSON returned from the API and inserts it into CoreData

     - parameters:
     - jsonMenu: a JSON object with the menu information
     - diningHall: the DiningHall enum that the menu corresponds to
     - completionHandler: a function to call at completion
     */
    private static func parseMenu(jsonMenu: JSON, diningHall: DiningHall, completionHandler: () -> ()) {
        let moc = self.managedObjectContext
        for (_,itemDictionary):(String,JSON) in jsonMenu {
            CoreDataMenuItem.createInManagedObjectContext(moc, menuItem: MenuItem(itemDict: itemDictionary, diningHall: diningHall))
        }
        completionHandler()
    }

    /**
     Wipe the CoreData (yesterday's menus).
    */
    private static func wipeStores() {
        let sc = NSPersistentStoreCoordinator()
        let stores = sc.persistentStores
        //        NSArray *stores = [persistentStoreCoordinator persistentStores];
        for store in stores {
            try? sc.removePersistentStore(store)
            try? NSFileManager.defaultManager().removeItemAtPath((store.URL?.path)!)
        }
    }

    /*

    /**
     This queries the API, one dining hall at a time, loading the results into CoreData in memory.

     This should only be called once a day
     */
    internal static func fetchMenusFromAPI() {
        menuCounter = 5
        wipeStores()

        for diningHall in DiningHall.allCases {
            self.getMenu(diningHall)
        }
    }

    /**
     This method queries the API for a given dining hall
     - parameters:
     - diningHall: the given dining hall
     */
    private static func getMenu(diningHall: DiningHall) {
        Alamofire.request(.GET, "https://dining.williams.edu/wp-json/dining/service_units/" + String(diningHall.getAPIValue())).responseJSON { (response) in
            guard response.result.error == nil else {
                print("Error occurred during menu request")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                self.parseMenu(JSON(value), diningHall: diningHall)
            }
        }
    }

    /**
     This method parses the JSON returned from the API and inserts it into CoreData

     - parameters:
     - jsonMenu: a JSON object with the menu information
     - diningHall: the DiningHall enum that the menu corresponds to
     */
    private static func parseMenu(jsonMenu: JSON, diningHall: DiningHall) {
        let moc = self.managedObjectContext
        for (_,itemDictionary):(String,JSON) in jsonMenu {
            CoreDataMenuItem.createInManagedObjectContext(moc, menuItem: MenuItem(itemDict: itemDictionary, diningHall: diningHall))
        }
        self.decrementMenuCounter()
    }

*/
    
}