//
//  MenuItem.swift
//  williams-dining
//
//  Created by Nathan Andersen on 6/29/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation


public struct MenuItem {
    var mealTime: MealTime = .Error
    var name: String = ""
    var diningHall: DiningHall = .Error
    var course: String = ""
    var isVegan: Bool = false
    var isGlutenFree: Bool = false

    let foodNameKey = "formal_name"
    let glutenFreeKey = " GF"
    let veganKey = " V"
    let mealKey = "meal"
    let courseKey = "course"

    init(itemDict: [String:AnyObject], diningHall: DiningHall) {
        let foodString = itemDict[foodNameKey] as! String
        self.isGlutenFree = foodString.containsString(glutenFreeKey)
        self.isVegan = foodString.containsString(veganKey)

        if isGlutenFree {
            self.name = foodString.substringToIndex(foodString.indexOf(glutenFreeKey))
        } else if isVegan {
            self.name = foodString.substringToIndex(foodString.indexOf(veganKey))
        } else {
            self.name = foodString
        }
        self.mealTime = MealTime(mealTime: itemDict[mealKey] as! String)
        self.diningHall = diningHall
        self.course = itemDict[courseKey] as! String
    }
}

extension String {
    func indexOf(string: String) -> String.Index {
        return rangeOfString(string, options: .LiteralSearch, range: nil, locale: nil)?.startIndex ?? startIndex
    }
}
