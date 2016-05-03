//
//  FavoritesNotifier.swift
//  williams-dining
//
//  Created by Nathan Andersen on 5/1/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

/**
 A data structure to track which favorite foods are on the menu, then send notifications.
 */
class FavoritesNotifier: NSObject {
    private var favoritesOnMenu: [MenuItem] = [MenuItem]()

    /**
     Add an item to the favorites list
    */
    internal func addToFavoritesList(item: MenuItem) {
//        print("was a favorite food")
        favoritesOnMenu.append(item)
    }

    /**
     Create and send out all notifications
    */
    internal func sendNotifications() {
        let date = NSDate()
        let dateAtStartOfDay = NSCalendar.currentCalendar().startOfDayForDate(date)
        var breakfastNotificationStr: String = ""
        var brunchNotificationStr: String = ""
        var lunchNotificationStr: String = ""
        var dinnerNotificationStr: String = ""
        var dessertNotificationStr: String = ""

        for item in favoritesOnMenu {
            let itemStr = "\(item.name) is being served at \(item.diningHall)\n"
            switch(item.mealTime) {
            case .Breakfast:
                breakfastNotificationStr.appendContentsOf(itemStr)
            case .Brunch:
                brunchNotificationStr.appendContentsOf(itemStr)
            case .Lunch:
                lunchNotificationStr.appendContentsOf(itemStr)
            case .Dinner:
                dinnerNotificationStr.appendContentsOf(itemStr)
            case .Dessert:
                dessertNotificationStr.appendContentsOf(itemStr)
            case _:
                break
            }
        }

        let fourPmWilliamstown = NSDate(timeInterval: 16*3600, sinceDate: dateAtStartOfDay)
        // if after 4 PM, then don't bother to send any notifications.
        if NSDate().compare(fourPmWilliamstown) != .OrderedAscending {
            return
        } else if !dinnerNotificationStr.isEmpty {
            let trimmedstr = dinnerNotificationStr.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
            let notification = UILocalNotification()
            notification.alertTitle = "Dinner"
            notification.alertBody = trimmedstr
            notification.alertAction = "view"
            notification.fireDate = fourPmWilliamstown
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }

        let tenThirtyAmWilliamstown = NSDate(timeInterval: 10.5*3600, sinceDate: dateAtStartOfDay)
        // if after 10:30, don't send lunch (or earlier) notifications
        if NSDate().compare(tenThirtyAmWilliamstown) != .OrderedAscending {
            return
        } else if !lunchNotificationStr.isEmpty {

            let trimmedstr = lunchNotificationStr.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())


            let notification = UILocalNotification()
            notification.alertTitle = "Lunch"
            notification.alertBody = trimmedstr
            notification.alertAction = "view"
            notification.fireDate = tenThirtyAmWilliamstown
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }

        let tenAmWilliamstown = NSDate(timeInterval: 10*3600, sinceDate: dateAtStartOfDay)
        // if after 10, don't send brunch or dessert or breakfast
        if NSDate().compare(tenAmWilliamstown) != .OrderedAscending {
            return
        } else {
            if !brunchNotificationStr.isEmpty {

                let trimmedstr = brunchNotificationStr.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())

                let notification = UILocalNotification()
                notification.alertTitle = "Brunch"
                notification.alertBody = trimmedstr
                notification.alertAction = "view"
                notification.fireDate = tenAmWilliamstown
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
            if !dessertNotificationStr.isEmpty {
                let trimmedstr = dessertNotificationStr.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())

                let notification = UILocalNotification()
                notification.alertTitle = "Dessert"
                notification.alertBody = trimmedstr
                notification.alertAction = "view"
                notification.fireDate = tenAmWilliamstown
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }

        let sevenAmWilliamstown = NSDate(timeInterval: 7*3600, sinceDate: dateAtStartOfDay)
        if NSDate().compare(sevenAmWilliamstown) != .OrderedAscending {
            return
        } else if !breakfastNotificationStr.isEmpty {

            let trimmedstr = breakfastNotificationStr.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())

            let notification = UILocalNotification()
            notification.alertTitle = "Breakfast"
            notification.alertBody = trimmedstr
            notification.alertAction = "view"
            notification.fireDate = sevenAmWilliamstown
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
}