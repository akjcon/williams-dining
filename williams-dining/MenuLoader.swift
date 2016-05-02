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

    /**
     This queries the API, one dining hall at a time, loading the results into
     CoreData in memory.
     
     - returns: the status of the Data
     - parameters:
        - completionHandler: a function to call at completion

 
    */
    internal static func fetchMenusFromAPI(completionHandler: (UIBackgroundFetchResult) -> Void) {
        var menusRemaining = 5
        self.clearCachedData()

        var favoritesNotifier = FavoritesNotifier()



        func completion() {
            menusRemaining -= 1
            print(menusRemaining)
            if menusRemaining == 0 {
                completionHandler(.NewData)
                (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
                favoritesNotifier.sendNotifications()
            }
        }

        for diningHall in DiningHall.allCases {
            self.getMenu(diningHall,favoritesNotifier: favoritesNotifier) {
                completion()
            }
        }
    }

    /**
     This method queries the API for a given dining hall
     - parameters:
        - diningHall: the given dining hall
        - favoritesNotifier: the FavoritesNotifier that will handle notifications
        - completionHandler: a function to call at completion
     */
    private static func getMenu(diningHall: DiningHall, favoritesNotifier: FavoritesNotifier, completionHandler: () -> ()) {
        Alamofire.request(.GET, "https://dining.williams.edu/wp-json/dining/service_units/" + String(diningHall.getAPIValue())).responseJSON { (response) in
            guard response.result.error == nil else {
                print("Error occurred during menu request")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                self.parseMenu(JSON(value), diningHall: diningHall, favoritesNotifier: favoritesNotifier) {
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
        - favoritesNotifier: the FavoritesNotifier that will handle notifications
        - completionHandler: a function to call at completion
     */
    private static func parseMenu(jsonMenu: JSON, diningHall: DiningHall, favoritesNotifier: FavoritesNotifier, completionHandler: () -> ()) {
        let moc = self.managedObjectContext
        for (_,itemDictionary):(String,JSON) in jsonMenu {
            let menuItem = MenuItem(itemDict: itemDictionary, diningHall: diningHall)
            CoreDataMenuItem.createInManagedObjectContext(moc, menuItem: menuItem)
            if MenuHandler.isAFavoriteFood(menuItem.name) {
                favoritesNotifier.addToFavoritesList(menuItem)
            }
        }
        completionHandler()
    }

    /**
     Clears the data stored in CoreData for new menu-space.
     */
    private static func clearCachedData() {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        fetchRequest.includesPropertyValues = false
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            for item in fetchResults! {
                managedObjectContext.deleteObject(item)
            }
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("save failed")
        }
    }
}
