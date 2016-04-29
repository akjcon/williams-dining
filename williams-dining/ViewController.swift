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
    @IBOutlet var activityLabel: UILabel!

    var orderedActivityLabels: [String] = ["Sipping the fresh Berkshire mountain air...",
                                           "Climbing the purple mountains...",
                                           "Yodeling...",
                                           "Herding the cows...",
                                           "Milking the cattle...",
                                           "Curdling milk...",
                                           "Mixing yogurt...",
                                           "Grilling steaks...",
                                           "Picking the vegetables...",
                                           "Mixing the salads...",
                                           "Loading menus..."]

    var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for diningHall in DiningHall.allCases {
            MenuRetriever.getMenus(diningHall)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.decrementDiningHallCounter), name: "decrementDiningHallCounter", object: nil)

        activityLabel.text = orderedActivityLabels[0]

        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(ViewController.changeActivityLabel), userInfo: nil, repeats: true)
    }

    /**
     Increment the text of the activity label.
     
     - postcondition: The activity label text has moved forward one in progression.
     */
    internal func changeActivityLabel() {
        let curIndex: Int = orderedActivityLabels.indexOf(activityLabel.text!)!
        activityLabel.text = orderedActivityLabels[curIndex + 1]
    }

    /**
     Decrement the dining hall counter, which starts at 5, to tell us that we have returned another menu.
     
     When at 0, enter the app.
    */
    internal func decrementDiningHallCounter() {
        diningHallCounter -= 1
        print(diningHallCounter)
        if diningHallCounter == 0 {
            print("all menus loaded")
            timer.invalidate()
            performSegueWithIdentifier("EnterApplicationSegue", sender: self)
        }
    }
}

