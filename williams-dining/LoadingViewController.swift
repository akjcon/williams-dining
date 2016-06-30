//
//  LoadingViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import UIKit
import CoreData

class LoadingViewController: PurpleStatusBarViewController {

    var diningHallCounter = 5
    @IBOutlet var activityLabel: UILabel!

    /**
     Some Williams-themed loading labels.
    */
    var orderedActivityLabels: [String] = ["Climbing the purple mountains...",
                                           "Yodeling...",
                                           "Herding the cows...",
                                           "Milking the cattle...",
                                           "Curdling milk...",
                                           "Mixing yogurt...",
                                           "Grilling steaks...",
                                           "Picking the vegetables...",
                                           "Mixing the salads...",
                                           "Wandering the steam tunnels",
                                           "Swimming in the Green River",
                                           "Loading menus..."]

    var timer: Timer?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityLabel.text = orderedActivityLabels[0]
    }

    internal func initializeLabelTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(LoadingViewController.changeActivityLabel), userInfo: nil, repeats: true)
    }

    internal func stopTimer() {
        timer?.invalidate()
    }


    /**
     Increment the text of the activity label.
     
     - postcondition: The activity label text has moved forward one in progression.
     */
    internal func changeActivityLabel() {
        let curIndex: Int = orderedActivityLabels.index(of: activityLabel.text!)!
        if curIndex == orderedActivityLabels.count - 1 {
            timer?.invalidate()
            // alert that the fetch must have failed
            (UIApplication.shared().delegate as! AppDelegate).loadingDataHadError()
            return
        }
        activityLabel.text = orderedActivityLabels[curIndex + 1]
    }
}

