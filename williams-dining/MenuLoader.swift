//
//  MenuLoader.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

/**
 This class queries the API for the JSON menus, then passes them to Core Data handlers.
 */
class MenuLoader {

    private static let apiBaseUrl = "https://dining.williams.edu/wp-json/dining/service_units/"
    private static let session = NSURLSession.sharedSession()
    private static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    /**
     This queries the API, one dining hall at a time, loading the results into
     CoreData in memory.
     
     - returns: the status of the Data
     - parameters:
        - completionHandler: a function to call at completion
    */
    internal static func fetchMenusFromAPI(completionHandler: (UIBackgroundFetchResult) -> Void) {
        var menusRemaining = 5
        MenuHandler.clearCachedData()
        let favoritesNotifier = FavoritesNotifier()

        for diningHall in DiningHall.allCases {
            self.getMenu(diningHall,favoritesNotifier: favoritesNotifier) {
                menusRemaining -= 1
                NSNotificationCenter.defaultCenter().postNotificationName(incrementLoadingProgressBarKey, object: nil)
                print("Fetched a menu. There are " + String(menusRemaining) + " menus remaining.")
                if menusRemaining == 0 {
                    print("Closing")
                    completionHandler(.NewData)
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
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = httpGet
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) in
            guard error == nil && (response as! NSHTTPURLResponse).statusCode == 200 else {
                print(error)
                self.appDelegate.loadingDataHadError()
                return
            }
            if let jsonObject: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) {
                MenuHandler.parseMenu(jsonObject, diningHall: diningHall, favoritesNotifier: favoritesNotifier) {
                    completionHandler()
                }
            } else {
                self.appDelegate.loadingDataHadError()
            }

        })
        task.resume()
    }

}
