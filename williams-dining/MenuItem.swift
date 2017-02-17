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
    let altVeganKey = " VGT"
    let mealKey = "meal"
    let courseKey = "course"
    let glutenFreeString = "gluten free"

    init(itemDict: [String:AnyObject], diningHall: DiningHall) {
        var foodString = itemDict[foodNameKey] as! String

        let whereVeganKeyWouldBeIndex = foodString.index(foodString.endIndex, offsetBy: -2)
        self.isVegan = (foodString.substring(from: whereVeganKeyWouldBeIndex) == veganKey)
        if isVegan {
            foodString = foodString.substring(to: whereVeganKeyWouldBeIndex)
        } else {
            let whereVeganKeyWouldBeAltIndex = foodString.index(foodString.endIndex, offsetBy: -4)
            self.isVegan = (foodString.substring(from: whereVeganKeyWouldBeAltIndex) == altVeganKey)
            if isVegan {
                foodString = foodString.substring(to: whereVeganKeyWouldBeAltIndex)
            }
        }

        let whereGlutenFreeKeyWouldBeIndex = foodString.index(foodString.endIndex, offsetBy: -3)

        self.isGlutenFree = (foodString.substring(from: whereGlutenFreeKeyWouldBeIndex) == glutenFreeKey)

        if isGlutenFree {
            foodString = foodString.substring(to: whereGlutenFreeKeyWouldBeIndex)
        }

        self.name = foodString

        self.isGlutenFree = self.isGlutenFree || foodString.localizedCaseInsensitiveContains(glutenFreeString)

        self.mealTime = MealTime(mealTime: itemDict[mealKey] as! String)
        self.diningHall = diningHall
        self.course = itemDict[courseKey] as! String
    }
}
