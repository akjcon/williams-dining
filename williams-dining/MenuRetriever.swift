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

enum MenuChoice {
    case Driscoll
    case Whitmans
    case Mission
    case GrabAndGo
    case EcoCafe

    func getAPIParameterValue() -> [String:AnyObject] {
        if self == .Driscoll {
            return ["":27]
        } else if self == .Mission {
            return ["":29]
        } else if self == .EcoCafe {
            return ["":38]
        } else if self == .GrabAndGo {
            return ["":209]
        } else if self == .Whitmans {
            return ["":208]
        }
        return [:]
    }

}

enum Meal {
    case Breakfast
    case Lunch
    case Dinner
    case Brunch
    case Bakeshop
}

struct MenuItem {
    var meal: Meal
}

class MenuRetriever: NSObject {

    var meals: [String] = []


    func getMenus(menuChoice: MenuChoice) {
        let parameters = menuChoice.getAPIParameterValue()

        
        Alamofire.request(.GET, "https://dining.williams.edu/wp-json/dining/service_units/27", parameters: parameters).responseJSON { (response) in

            guard response.result.error == nil else {
                print("Error occurred during menu request")
                print(response.result.error!)
                return
            }
            if let value: AnyObject = response.result.value {
                self.parseMenu(JSON(value))
            }
        }
    }

    private func parseMenu(jsonMenu: JSON) {
        print(jsonMenu)

        for (_,subJSON):(String,JSON) in jsonMenu {

        }

/*        for (_,subJson):(String, JSON) in tracks {
            let song = Song(
                title: subJson["name"].string,
                description: subJson["artists"][0]["name"].string,
                service: Service.Spotify,
                trackId: subJson["id"].string!,
                artworkURL: NSURL(string: subJson["album"]["images"][1]["url"].string!))

            songs += [song]
        }

        return songs*/
    }
}