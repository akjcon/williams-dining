//
//  MenuRetriever.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MenuRetriever: NSObject {

    static func getMenus(diningHall: DiningHall) {
        Alamofire.request(.GET, "https://dining.williams.edu/wp-json/dining/service_units/" + String(diningHall.getIntValue())).responseJSON { (response) in
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

    static func parseMenu(jsonMenu: JSON, diningHall: DiningHall) {
        var items = [MenuItem]()
        for (_,item):(String,JSON) in jsonMenu {
            items.append(MenuItem(item: item,diningHall: diningHall))
        }
        diningHallMenus[diningHall] = items
        NSNotificationCenter.defaultCenter().postNotificationName("decrementDiningHallCounter", object: nil)
    }
}