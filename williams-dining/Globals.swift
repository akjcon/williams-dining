//
//  Globals.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import SwiftyJSON

var diningHallMenus = [DiningHall:[MenuItem]]()

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
}

enum MealTime {
    case Breakfast
    case Lunch
    case Dinner
    case Brunch
    case Dessert
    case Error

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

    init(item: JSON, diningHall: DiningHall) {
        self.mealTime = MealTime(mealTime: item["meal"].string!)
        self.food = item["formal_name"].string!
        self.diningHall = diningHall
        self.course = item["course"].string!
    }
}
