//
//  Globals.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import SwiftyJSON

// data structure:
// dining hall -> meals
// meals -> dining halls

// then build scrolling tables w/ headers
var diningHallMenus = [DiningHall:[MenuItem]]()
var mealMenus = [MealTime:[MenuItem]]()

enum DiningHall {
    case Driscoll
    case Whitmans
    case Mission
    case GrabAndGo
    case EcoCafe

    static let allCases = [Driscoll,Whitmans,Mission,GrabAndGo,EcoCafe]

    func getIntValue() -> Int {
        if self == .Driscoll {
            return 27
        } else if self == .Mission {
            return 29
        } else if self == .EcoCafe {
            return 38
        } else if self == .GrabAndGo {
            return 209
        } else if self == .Whitmans {
            return 208
        }
        return 0
    }

    func getStringValue() -> String {
        if self == .Driscoll {
            return "Driscoll"
        } else if self == .Mission {
            return "Mission"
        } else if self == .EcoCafe {
            return "Eco Cafe"
        } else if self == .GrabAndGo {
            return "Grab and Go"
        } else if self == .Whitmans {
            return "Whitmans"
        }
        return ""
    }
}

enum MealTime {
    case Breakfast
    case Lunch
    case Dinner
    case Brunch
    case Dessert
    case Error

    static let allCases = [Breakfast,Lunch,Dinner,Brunch,Dessert]
    
    init(mealTime: String) {
        switch(mealTime.lowercaseString) {
        case "breakfast":
            self = .Breakfast
        case "lunch":
            self = .Lunch
        case "dinner":
            self = .Dinner
        case "brunch":
            self = .Brunch
        case "williams' bakeshop":
            self = .Dessert
        case _:
            self = .Error
        }
    }
}

struct MenuItem {
    var mealTime: MealTime
    var food: String
    var diningHall: DiningHall
    var course: String

    init(itemDict: JSON, diningHall: DiningHall) {
        self.mealTime = MealTime(mealTime: itemDict["meal"].string!)
        self.food = itemDict["formal_name"].string!
        self.diningHall = diningHall
        self.course = itemDict["course"].string!
    }

    // flesh this out WRT data structure
    func addToDataStructure() {
        var dhList = diningHallMenus[diningHall]
        if dhList == nil {
            diningHallMenus[diningHall] = [self]
        } else {
            dhList!.append(self)
            diningHallMenus[diningHall] = dhList
        }

        var mealList = mealMenus[mealTime]
        if mealList == nil {
            mealMenus[mealTime] = [self]
        } else {
            mealList!.append(self)
            mealMenus[mealTime] = mealList
        }
    }
}
