//
//  FavoritesNotifier.swift
//  williams-dining
//
//  Created by Nathan Andersen on 5/1/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
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
        favoritesOnMenu.append(item)
    }

    /**
     Create and send out all notifications
    */
    internal func sendNotifications() {
        let date = NSDate()
        let dateAtStartOfDay = Calendar.current().startOfDay(for: date as Date)
        var breakfastNotificationStr: String = ""
        var brunchNotificationStr: String = ""
        var lunchNotificationStr: String = ""
        var dinnerNotificationStr: String = ""
        var dessertNotificationStr: String = ""

        for item in favoritesOnMenu {
            let itemStr = "\(item.name) is being served at \(item.diningHall)\n"
            switch(item.mealTime) {
            case .Breakfast:
                breakfastNotificationStr.append(itemStr)
            case .Brunch:
                brunchNotificationStr.append(itemStr)
            case .Lunch:
                lunchNotificationStr.append(itemStr)
            case .Dinner:
                dinnerNotificationStr.append(itemStr)
            case .Dessert:
                dessertNotificationStr.append(itemStr)
            case _:
                break
            }
        }

        let fourPmWilliamstown = Date(timeInterval: 16*3600, since: dateAtStartOfDay)
        // if after 4 PM, then don't bother to send any notifications.
        if NSDate().compare(fourPmWilliamstown as Date) != .orderedAscending {
            return
        } else if !dinnerNotificationStr.isEmpty {
            let trimmedstr = dinnerNotificationStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let notification = UILocalNotification()
            notification.alertTitle = "Dinner"
            notification.alertBody = trimmedstr
            notification.alertAction = "view"
            notification.fireDate = fourPmWilliamstown
            UIApplication.shared().scheduleLocalNotification(notification)
        }

        let tenThirtyAmWilliamstown = Date(timeInterval: 10.5*3600, since: dateAtStartOfDay)
        // if after 10:30, don't send lunch (or earlier) notifications
        if Date().compare(tenThirtyAmWilliamstown) != .orderedAscending {
            return
        } else if !lunchNotificationStr.isEmpty {

            let trimmedstr = lunchNotificationStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)


            let notification = UILocalNotification()
            notification.alertTitle = "Lunch"
            notification.alertBody = trimmedstr
            notification.alertAction = "view"
            notification.fireDate = tenThirtyAmWilliamstown
            UIApplication.shared().scheduleLocalNotification(notification)
        }

        let tenAmWilliamstown = Date(timeInterval: 10*3600, since: dateAtStartOfDay)
        // if after 10, don't send brunch or dessert or breakfast
        if NSDate().compare(tenAmWilliamstown) != .orderedAscending {
            return
        } else {
            if !brunchNotificationStr.isEmpty {

                let trimmedstr = brunchNotificationStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                let notification = UILocalNotification()
                notification.alertTitle = "Brunch"
                notification.alertBody = trimmedstr
                notification.alertAction = "view"
                notification.fireDate = tenAmWilliamstown
                UIApplication.shared().scheduleLocalNotification(notification)
            }
            if !dessertNotificationStr.isEmpty {
                let trimmedstr = dessertNotificationStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                let notification = UILocalNotification()
                notification.alertTitle = "Dessert"
                notification.alertBody = trimmedstr
                notification.alertAction = "view"
                notification.fireDate = tenAmWilliamstown
                UIApplication.shared().scheduleLocalNotification(notification)
            }
        }

        let sevenAmWilliamstown = Date(timeInterval: 7*3600, since: dateAtStartOfDay)
        if NSDate().compare(sevenAmWilliamstown) != .orderedAscending {
            return
        } else if !breakfastNotificationStr.isEmpty {

            let trimmedstr = breakfastNotificationStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            let notification = UILocalNotification()
            notification.alertTitle = "Breakfast"
            notification.alertBody = trimmedstr
            notification.alertAction = "view"
            notification.fireDate = sevenAmWilliamstown
            UIApplication.shared().scheduleLocalNotification(notification)
        }
    }
}
