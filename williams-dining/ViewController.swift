//
//  ViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var diningHallMenus = [DiningHall:[MenuItem]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for diningHall in DiningHall.allCases {
            diningHallMenus[diningHall] = MenuRetriever.getMenus(diningHall)
        }
        // aah, it's asynchronous...
        
        for diningHall in DiningHall.allCases {
            print(diningHall)
            let menuItems = diningHallMenus[diningHall]!
            print(menuItems)
            for item in menuItems {
                print(item)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

