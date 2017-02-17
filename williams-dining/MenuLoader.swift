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
    private static let session = URLSession.shared
    private static let appDelegate = UIApplication.shared.delegate as! AppDelegate

    /**
     This queries the API, one dining hall at a time, loading the results into
     CoreData in memory.
     
     - returns: the status of the Data
     - parameters:
        - completionHandler: a function to call at completion
    */
    internal static func fetchMenusFromAPI(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        var menusRemaining = 5
        MenuHandler.clearCachedData()
        let favoritesNotifier = FavoritesNotifier()

        var success = true

        for diningHall in DiningHall.allCases {
            self.getMenu(diningHall: diningHall,favoritesNotifier: favoritesNotifier) {
                (result: Bool) in
                menusRemaining -= 1
                NotificationCenter.default.post(name: incrementLoadingProgressBarKey, object: nil)
                print("A menu returned. It was successful: \(success). There are \(menusRemaining) menus remaining.")
                success = success && result
                if menusRemaining == 0 {
                    if !success {
                        print("there was an error")
                        self.appDelegate.loadingDataHadError()
                        return
                    }
                    print("All menus fetched.")
                    appDelegate.saveContext()
                    favoritesNotifier.sendNotifications()
                    completionHandler(.newData)
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
    private static func getMenu(diningHall: DiningHall, favoritesNotifier: FavoritesNotifier, completionHandler: @escaping (Bool) -> ()) {
        let url = apiBaseUrl + String(diningHall.getAPIValue())
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = httpGet
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            guard error == nil && (response as! HTTPURLResponse).statusCode == 200 else {
                print(error!)
//                self.appDelegate.loadingDataHadError()
                completionHandler(false)
                return
            }
            if let jsonObject: AnyObject = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject? {
                MenuHandler.parseMenu(menu: jsonObject, diningHall: diningHall, favoritesNotifier: favoritesNotifier) {
                    completionHandler(true)
                }
            } else {
                completionHandler(false)
//                self.appDelegate.loadingDataHadError()
            }

        })
        task.resume()
    }

}
