//
//  MenuLoader.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData
//import SwiftyJSON
//import Alamofire

/**
 This class queries the API for the JSON menus, then loads them into CoreData memory.
 */
class MenuLoader: NSObject {

    private static let apiBaseUrl = "https://dining.williams.edu/wp-json/dining/service_units/"
    private static let session = URLSession.shared()

    private static let appDelegate = UIApplication.shared().delegate as! AppDelegate



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
        let favoritesNotifier = FavoritesNotifier()

        for diningHall in DiningHall.allCases {
            self.getMenu(diningHall: diningHall,favoritesNotifier: favoritesNotifier) {
                menusRemaining -= 1
                NotificationCenter.default().post(name: incrementLoadingProgressBarKey, object: nil)
                print("Fetched a menu. There are " + String(menusRemaining) + " menus remaining.")
                if menusRemaining == 0 {
                    print("Closing")
                    completionHandler(.newData)
                    appDelegate.saveContext()
                    favoritesNotifier.sendNotifications()
                }
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
        let url = apiBaseUrl + String(diningHall.getAPIValue())
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = httpGet
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            guard error == nil && (response as! HTTPURLResponse).statusCode == 200 else {
                print(error)
                self.appDelegate.loadingDataHadError()
                return
            }
            if let jsonObject: AnyObject = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) {
                self.parseMenu(menu: jsonObject, diningHall: diningHall, favoritesNotifier: favoritesNotifier) {
                    completionHandler()
                }
            } else {
                self.appDelegate.loadingDataHadError()
            }

        })
        task.resume()
    }

    /**
     This method parses the JSON returned from the API and inserts it into CoreData

     - parameters:
        - jsonMenu: a JSON object with the menu information
        - diningHall: the DiningHall enum that the menu corresponds to
        - favoritesNotifier: the FavoritesNotifier that will handle notifications
        - completionHandler: a function to call at completion
     */
    private static func parseMenu(menu: AnyObject, diningHall: DiningHall, favoritesNotifier: FavoritesNotifier, completionHandler: () -> ()) {
        let moc = self.appDelegate.managedObjectContext
        if let menuItems: [[String:AnyObject]] = menu as? [[String:AnyObject]] {
            for itemDict in menuItems {
                let menuItem = MenuItem(itemDict: itemDict, diningHall: diningHall)
                _ = CoreDataMenuItem.createInManagedObjectContext(moc: moc, menuItem: menuItem)
                if MenuHandler.isAFavoriteFood(name: menuItem.name) {
                    favoritesNotifier.addToFavoritesList(item: menuItem)
                }
            }
            completionHandler()
        } else {
            print("Error in menu parsing. Here is the menu")
            print(menu)
        }

    }

    /**
     Clears the data stored in CoreData for new menu-space.
     */
    private static func clearCachedData() {
        let moc = self.appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataMenuItem")
        fetchRequest.includesPropertyValues = false
        if let fetchResults = try? moc.fetch(fetchRequest) as? [CoreDataMenuItem] {
            for item in fetchResults! {
                moc.delete(item)
            }
        }
        do {
            try moc.save()
        } catch {
            print("While clearing the menus, the save failed")
        }
    }
}
