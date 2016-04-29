//
//  ViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var diningHallCounter = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for diningHall in DiningHall.allCases {
            MenuRetriever.getMenus(diningHall)
//            diningHallMenus[diningHall] = MenuRetriever.getMenus(diningHall)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.decrementDiningHallCounter), name: "decrementDiningHallCounter", object: nil)
    }

    // two options:
    // meals by dining hall
    // dining halls by meal

    func decrementDiningHallCounter() {
        diningHallCounter -= 1
        print(diningHallCounter)
        if diningHallCounter == 0 {
            print("all menus loaded")
            self.updateDisplay()
            // update display // show ready or whatever
        }
    }

    func updateDisplay() {
        for diningHall in DiningHall.allCases {
            print(diningHall)
            let menuItems = diningHallMenus[diningHall]!
            print(menuItems.count)
/*            for item in menuItems {
                print("hello")
                print(item)
            }*/
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

