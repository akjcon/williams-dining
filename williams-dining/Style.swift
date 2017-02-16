//
//  Style.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/29/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

enum Theme {
    case Standard
    case Test
}
/**
 This contains the global style for the app
 */
struct Style {

    static var theme: Theme = .Standard



    static var defaultColor: UIColor {
        switch Style.theme {
        case .Standard:
            return purpleColor
        case .Test:
            return UIColor.red
        }
    }


    static var secondaryColor: UIColor {
        switch Style.theme {
        case .Standard:
            return yellowColor
        case .Test:
            return UIColor.green
        }
    }
//    static var defaultColor = purpleColor

//    static var defaultColor = UIColor.red
//    static var secondaryColor = UIColor.green

//    static var secondaryColor = yellowColor
    static var clearColor = UIColor.clear

    private static var purpleColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 0.9)
    private static var yellowColor = UIColor.yellow

}
