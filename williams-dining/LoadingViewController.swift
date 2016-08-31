//
//  LoadingViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import UIKit
import CoreData

let incrementLoadingProgressBarKey = "incrementLoadingProgressBar"

public class LoadingViewController: PurpleStatusBarViewController {

    var diningHallsReturned: Float = 0
    let diningHallCount: Float = 5
    @IBOutlet var activityLabel: UILabel!

    @IBOutlet var progressBar: UIProgressView!
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

    var timer: NSTimer?

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("view did appear")
        diningHallsReturned = 0
        progressBar.setProgress(0, animated: true)
        activityLabel.text = orderedActivityLabels[0]
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoadingViewController.incrementProgress), name: incrementLoadingProgressBarKey, object: nil)
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: incrementLoadingProgressBarKey, object: nil)
    }

    internal func initializeLabelTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(LoadingViewController.changeActivityLabel), userInfo: nil, repeats: true)
    }

    internal func stopTimer() {
        timer?.invalidate()
    }

    internal func incrementProgress() {
        dispatch_async(dispatch_get_main_queue(), {
            self.diningHallsReturned += 1
//            self.setProgress(self.diningHallsReturned/self.diningHallCount)
            self.progressBar.setProgress(self.diningHallsReturned/self.diningHallCount, animated: true)
        })
    }

/*    internal func setProgress(progress: Float) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            self.progressBar.setProgress(progress, animated: true)
        })
    }*/

    /**
     Increment the text of the activity label.
     
     - postcondition: The activity label text has moved forward one in progression.
     */
    internal func changeActivityLabel() {
        let curIndex: Int = orderedActivityLabels.indexOf(activityLabel.text!)!
        if curIndex == orderedActivityLabels.count - 1 {
            timer?.invalidate()
            // alert that the fetch must have failed
            (UIApplication.sharedApplication().delegate as! AppDelegate).loadingDataHadError()
            return
        }
        activityLabel.text = orderedActivityLabels[curIndex + 1]
    }
}

