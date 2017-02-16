//
//  Style.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/29/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

/**
 This contains the global style for the app
 */
struct Style {

    static func initialize() {
        print("initializing colors")

        


        // initialize colors here
            //        UILabel.appearance().tintColor = Style.secondaryColor
            //        UILabel.appearance().backgroundColor = Style.defaultColor

            // UITabBarController

            // UITableView

            // UITableViewCell

            // UIButton

            // UIProgressBar
            
            // UILoadingIndicator (or whatever it is)
            
            //        UITableView.appearance().tintColor

    }

    static var defaultColor = purpleColor

//    static var defaultColor = UIColor.red

    static var secondaryColor = yellowColor
    static var clearColor = UIColor.clear

    private static var purpleColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 0.9)
    private static var yellowColor = UIColor.yellow

}
