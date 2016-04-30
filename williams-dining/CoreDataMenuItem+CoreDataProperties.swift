//
//  CoreDataMenuItem+CoreDataProperties.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import SwiftyJSON

extension CoreDataMenuItem {

    @NSManaged var isVegan: Bool
    @NSManaged var isGlutenFree: Bool
    @NSManaged var name: String
    @NSManaged var mealTime: NSNumber
    @NSManaged var diningHall: NSNumber
    @NSManaged var course: String
}




enum DiningHall {
    case Driscoll
    case Whitmans
    case Mission
    case GrabAndGo
    case EcoCafe
    case Error

    init(num: NSNumber) {
        switch(num) {
        case 1:
            self = .Driscoll
        case 2:
            self = .Whitmans
        case 3:
            self = .Mission
        case 4:
            self = .GrabAndGo
        case 5:
            self = .EcoCafe
        default:
            self = .Error
        }
    }

    func intValue() -> Int {
        switch(self) {
        case .Driscoll:
            return 1
        case .Whitmans:
            return 2
        case .Mission:
            return 3
        case .GrabAndGo:
            return 4
        case .EcoCafe:
            return 5
        case .Error:
            return 10
        }
    }

    static let allCases = [Driscoll,Whitmans,Mission,GrabAndGo,EcoCafe]

    func getAPIValue() -> Int {
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

    func stringValue() -> String {
        if self == .Driscoll {
            return "Driscoll"
        } else if self == .Mission {
            return "Mission"
        } else if self == .EcoCafe {
            return "Eco Cafe"
        } else if self == .GrabAndGo {
            return "Grab and Go"
        } else if self == .Whitmans {
            return "Whitman's"
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

    init(num: NSNumber) {
        switch(num) {
        case 1:
            self = .Breakfast
        case 2:
            self = .Brunch
        case 3:
            self = .Lunch
        case 4:
            self = .Dinner
        case 5:
            self = .Dessert
        default:
            self = .Error
        }
    }

    func stringValue() -> String {
        switch(self) {
        case .Breakfast:
            return "Breakfast"
        case .Brunch:
            return "Brunch"
        case .Lunch:
            return "Lunch"
        case .Dinner:
            return "Dinner"
        case .Dessert:
            return "Dessert"
        case .Error:
            return ""
        }
}

    func intValue() -> Int {
        switch(self) {
        case .Breakfast:
            return 1
        case .Brunch:
            return 2
        case .Lunch:
            return 3
        case .Dinner:
            return 4
        case .Dessert:
            return 5
        case .Error:
            return 10
        }
}

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
    var mealTime: MealTime = .Error
    var name: String = ""
    var diningHall: DiningHall = .Error
    var course: String = ""
    var isVegan: Bool = false
    var isGlutenFree: Bool = false

    init(itemDict: JSON, diningHall: DiningHall) {
        let foodString = itemDict["formal_name"].string!

        self.isGlutenFree = foodString.containsString(" GF")
        self.isVegan = foodString.containsString(" V")

        if isGlutenFree {
            self.name = foodString.substringToIndex(foodString.indexOf(" GF"))
        } else if isVegan {
            self.name = foodString.substringToIndex(foodString.indexOf(" V"))
        } else {
            self.name = foodString
        }

        self.mealTime = MealTime(mealTime: itemDict["meal"].string!)
//        self.name = foodString
        self.diningHall = diningHall
        self.course = itemDict["course"].string!
    }
}

extension String {
    func indexOf(string: String) -> String.Index {
        return rangeOfString(string, options: .LiteralSearch, range: nil, locale: nil)?.startIndex ?? startIndex
    }
}
