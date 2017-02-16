//
//  LoadingViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import UIKit
import CoreData

let incrementLoadingProgressBarKey = Notification.Name("incrementLoadingProgressBar")

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

    var timer: Timer?

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view did appear")
        diningHallsReturned = 0
        progressBar.setProgress(0, animated: true)
        activityLabel.text = orderedActivityLabels[0]
        NotificationCenter.default.addObserver(self, selector: #selector(LoadingViewController.incrementProgress), name: incrementLoadingProgressBarKey, object: nil)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: incrementLoadingProgressBarKey, object: nil)
    }

    internal func initializeLabelTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(LoadingViewController.changeActivityLabel), userInfo: nil, repeats: true)
    }

    internal func stopTimer() {
        timer?.invalidate()
    }

    internal func incrementProgress() {
        DispatchQueue.main.sync(execute: {
            diningHallsReturned += 1
            progressBar.setProgress(diningHallsReturned/diningHallCount, animated: true)
        })
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
            (UIApplication.shared.delegate as! AppDelegate).loadingDataHadError()
            return
        }
        activityLabel.text = orderedActivityLabels[curIndex + 1]
    }
}

