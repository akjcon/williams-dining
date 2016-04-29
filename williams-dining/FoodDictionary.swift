//
//  FoodDictionary.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

import CoreData

var foodDictionary: FoodDictionary!

class FoodDictionary: NSObject {

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    /**
     Fetch all menu items for a given diningHall and a given mealTime
     
     - parameters:
        - diningHall: the selected diningHall
        - mealTime: the selected mealTime
     
     SELECT *
     FROM CoreData
     WHERE  diningHall = diningHall
        AND mealTime = mealTime
    */
    func fetchByMealTimeAndDiningHall(mealTime: MealTime, diningHall: DiningHall) -> [CoreDataMenuItem] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")

        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "course", ascending: true)

        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]

        let firstPredicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall.intValue()))
        let secondPredicate = NSPredicate(format: "%K == %@", "mealTime", NSNumber(integer: mealTime.intValue()))


        // Set the predicate on the fetch request
        fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [firstPredicate,secondPredicate])

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {

            return fetchResults!
        }
        return []

    }

    /**
     Fetch all active dining halls from Core Data
     
     SELECT UNIQUE diningHall
     FROM CoreData
    */
    func fetchActiveDiningHalls() -> [DiningHall] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")
        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            var diningHalls = Set<DiningHall>()
            fetchResults!.forEach({
                diningHalls.insert(DiningHall(num: $0.diningHall))
            })
            return Array(diningHalls).sort({$0.intValue() < $1.intValue() })
        }
        return []
    }

    /**
     Fetch active meal times for a given dining hall
     
     - parameters:
        - diningHall: the selected diningHall
     
     SELECT UNIQUE mealTime
     FROM CoreData
     WHERE diningHall = diningHall
    */
    func fetchMealTimesForDiningHall(diningHall: DiningHall) -> [MealTime] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")

        // consider a sort descriptor?

        let predicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall.intValue()))

        fetchRequest.predicate = predicate

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {

            var mealTimes = Set<MealTime>()
            fetchResults!.forEach({
                mealTimes.insert(MealTime(num: $0.mealTime))
            })
            return Array(mealTimes).sort({$0.intValue() < $1.intValue() })
        }
        return []
    }

    func fetchDiningHallItems(diningHall: DiningHall) -> [CoreDataMenuItem] {
        let fetchRequest = NSFetchRequest(entityName: "CoreDataMenuItem")

        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "course", ascending: true)

        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]

        let predicate = NSPredicate(format: "%K == %@", "diningHall", NSNumber(integer: diningHall.intValue()))


        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        if let fetchResults = try? managedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataMenuItem] {
            return fetchResults!
        }
        return []
    }

    override init() {
        super.init()

        // temporarily here, but later will move this to auto-update or something
        self.fetchMenus()
    }

    private var menuCounter = 5

    private func decrementMenuCounter() {
        menuCounter -= 1
        print(menuCounter)

        if menuCounter == 0 {
            NSNotificationCenter.defaultCenter().postNotificationName("dataIsReady", object: nil)
        }
    }

    /**
     This queries the API and loads all menus into memory
    */
    private func fetchMenus() {
        for diningHall in DiningHall.allCases {
            self.getMenu(diningHall)
        }
    }

    private func getMenu(diningHall: DiningHall) {
        Alamofire.request(.GET, "https://dining.williams.edu/wp-json/dining/service_units/" + String(diningHall.getAPIValue())).responseJSON { (response) in
            guard response.result.error == nil else {
                print("Error occurred during menu request")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                self.parseMenu(JSON(value), diningHall: diningHall)
            }
        }
    }

    private func parseMenu(jsonMenu: JSON, diningHall: DiningHall) {
        let moc = self.managedObjectContext
        for (_,itemDictionary):(String,JSON) in jsonMenu {
            CoreDataMenuItem.createInManagedObjectContext(moc, menuItem: MenuItem(itemDict: itemDictionary, diningHall: diningHall))
        }
        self.decrementMenuCounter()
    }

    private var activeMealTimes = [MealTime]()

    private var activeDiningHalls = [DiningHall]()

    private var mealTimesForDiningHalls = [DiningHall:[MealTime]]()
    // Dining Halls -> Meal Times (keys for diningHallMenus)
    private var diningHallMenus = [DiningHall:[MealTime:[MenuItem]]]()
    // Dining Halls -> Meal Times -> Menu Items

    private var mealMenus = [MealTime:[DiningHall:[MenuItem]]]()
    // Meal Times -> Dining Halls -> Menu Items
    private var diningHallsForMealTimes = [MealTime:[DiningHall]]()
    // Meal Times -> Dining Halls (keys for mealMenus)

    func getActiveMealTimes() -> [MealTime] {
        return activeMealTimes.sort({$0.intValue() < $1.intValue() })
    }

    func getActiveDiningHalls() -> [DiningHall] {
        return activeDiningHalls.sort({$0.intValue() < $1.intValue() })
    }


    func getMealTimesForDiningHall(diningHall: DiningHall) -> [MealTime]? {
        let mealTimes = mealTimesForDiningHalls[diningHall]
        if mealTimes == nil {
            return []
        } else {
            return mealTimes!.sort({$0.intValue() < $1.intValue() })
        }
    }

    func getDiningHallsForMealTime(mealTime: MealTime) -> [DiningHall]? {
        let diningHalls = diningHallsForMealTimes[mealTime]
        if diningHalls == nil {
            return []
        } else {
            return diningHalls!.sort({$0.intValue() < $1.intValue() })
        }
    }


    func getDiningHallMenu(diningHall: DiningHall) -> [MealTime:[MenuItem]]? {
        return diningHallMenus[diningHall]
    }

    func getMealMenu(mealTime: MealTime) -> [DiningHall:[MenuItem]]? {
        return mealMenus[mealTime]
    }

    func addItemToDiningHallDict(item: MenuItem) {
        // add it to dict of keys
        var mealKeys = mealTimesForDiningHalls[item.diningHall]
        if mealKeys == nil {
            mealKeys = [item.mealTime]
        } else {
            if !mealKeys!.contains(item.mealTime) {
                mealKeys!.append(item.mealTime)
            }
        }
        mealTimesForDiningHalls[item.diningHall] = mealKeys


        // add it to the dict of dicts
        var diningHallDict = diningHallMenus[item.diningHall]
        if diningHallDict == nil {
            diningHallDict = [item.mealTime:[item]]
        } else {
            var mealDict = diningHallDict![item.mealTime]
            if mealDict == nil {
                mealDict = [item]
            } else {
                mealDict?.append(item)
            }
            diningHallDict![item.mealTime] = mealDict
        }
        diningHallMenus[item.diningHall] = diningHallDict

    }

    func addItemToMealDict(item: MenuItem) {
        // add it to dict of keys
        var diningHallKeys = diningHallsForMealTimes[item.mealTime]
        if diningHallKeys == nil {
            diningHallKeys = [item.diningHall]
        } else {
            if !diningHallKeys!.contains(item.diningHall) {
                diningHallKeys!.append(item.diningHall)
            }
        }
        diningHallsForMealTimes[item.mealTime] = diningHallKeys


        // add to dict of dicts
        var mealDict = mealMenus[item.mealTime]
        if mealDict == nil {
            mealDict = [item.diningHall:[item]]
        } else {
            var diningHallDict = mealDict![item.diningHall]
            if diningHallDict == nil {
                diningHallDict = [item]
            } else {
                diningHallDict?.append(item)
            }
            mealDict![item.diningHall] = diningHallDict
        }
        mealMenus[item.mealTime] = mealDict
    }


    func addMenuItem(item: MenuItem) {
        if !activeMealTimes.contains(item.mealTime) {
            activeMealTimes.append(item.mealTime)
        }

        if !activeDiningHalls.contains(item.diningHall) {
            activeDiningHalls.append(item.diningHall)
        }


        addItemToDiningHallDict(item)
        addItemToMealDict(item)
    }
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
