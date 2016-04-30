//
//  ViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var diningHallCounter = 5
    @IBOutlet var activityLabel: UILabel!

    var orderedActivityLabels: [String] = ["Climbing the purple mountains...",
                                           "Yodeling...",
                                           "Herding the cows...",
                                           "Milking the cattle...",
                                           "Curdling milk...",
                                           "Mixing yogurt...",
                                           "Grilling steaks...",
                                           "Picking the vegetables...",
                                           "Mixing the salads...",
                                           "Loading menus..."]

    var timer: NSTimer?

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.pushToMenus), name: "dataIsReady", object: nil)
        activityLabel.text = orderedActivityLabels[0]
    }

    internal func initializeLabelTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(ViewController.changeActivityLabel), userInfo: nil, repeats: true)
    }

    internal func pushToMenus() {
        if timer != nil {
            timer!.invalidate()
        }
        performSegueWithIdentifier("EnterApplicationSegue", sender: self)
    }


    /**
     Increment the text of the activity label.
     
     - postcondition: The activity label text has moved forward one in progression.
     */
    internal func changeActivityLabel() {
        let curIndex: Int = orderedActivityLabels.indexOf(activityLabel.text!)!

        if curIndex == orderedActivityLabels.count - 1 {
            timer?.invalidate()
            // alert that the fetch must have failed
            self.presentViewController(UIAlertController(title: "Error", message: "Loading the menus timed out.\n\nPlease close the app and try again.", preferredStyle: .Alert),animated: true,completion: nil)

            return
        }
        activityLabel.text = orderedActivityLabels[curIndex + 1]
    }
}

