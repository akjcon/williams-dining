//
//  ReviewsViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 7/1/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class RoundedBorderedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.layer.borderColor = tintColor.CGColor
    }

}

class ReviewsViewController: DefaultTableViewController {

    @IBOutlet var submitButton: RoundedBorderedButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var suggestionBox: UITextView!
    var pickerDataSource: [DiningHall] = [.Error]

    private var alertController: UIAlertController?

    private let serverErrorTitle = "Server error"
    private let serverErrorBody = "Could not connect to the server. Try again?"

    private let comingSoonTitle = "Coming soon"
    private let comingSoonBody = "Review collection coming soon.\n\nLook for an update in the coming weeks!"

    private let userErrorTitle = "No feedback provided"
    private let userErrorBody = "Please provide ratings or a suggestion before submitting."

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReviewsViewController.keyboardWillBeShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReviewsViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.refreshView()
        setSubmitButtonTitle("Submit")
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.refreshView()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        setSubmitButtonTitle("Submit")
    }

    func refreshView() {
        pickerDataSource = MenuHandler.fetchDiningHalls(nil)
        pickerView.selectRow(0, inComponent: 0, animated: true)
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })
    }

    @IBAction func userDidTapOutsideTextArea(sender: UITapGestureRecognizer) {
        if suggestionBox.isFirstResponder() {
            suggestionBox.resignFirstResponder()
        }
        setSubmitButtonTitle("Submit")
    }

    func setSubmitButtonTitle(title: String) {
        submitButton.setTitle(title, forState: [])
    }

    func keyboardWillBeShown(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.window!.frame.origin.y = -1 * keyboardSize.height
        }
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        self.view.window!.frame = UIScreen.mainScreen().bounds
    }

    @IBAction func submitReviews() {

        submitButton.userInteractionEnabled = false
        submitButton.selected = true

        let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(selectedDiningHall)[pickerView.selectedRowInComponent(1)]

        ReviewHandler.submitReviews(selectedDiningHall, mealTime: selectedMealTime, suggestion: suggestionBox.text) {
            (userProvidedFeedback: Bool, serverError: Bool) in
            self.submitButton.userInteractionEnabled = true
            self.submitButton.selected = false

            self.displayErrorMessage(self.comingSoonTitle, body: self.comingSoonBody)

            /*
            if !userProvidedFeedback {
                self.displayErrorMessage(title: self.userErrorTitle, body: self.userErrorBody)
            } else if serverError {
                self.displayErrorMessage(title: self.serverErrorTitle, body: self.serverErrorBody)
            } else {
                ReviewHandler.clearRatings()
                self.setSubmitButtonTitle(title: "Thank you!")
                self.resetSuggestionBoxToPlaceholder()
            }*/
            self.tableView.reloadData()
        }
    }

    private func displayErrorMessage(title: String, body: String) {
        if alertController == nil {
            alertController = UIAlertController(title: title, message: body, preferredStyle: .Alert)
            alertController?.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        } else {
            alertController?.title = title
            alertController?.message = body
        }
        self.presentViewController(alertController!, animated: true, completion: nil)
    }

    func resetSuggestionBoxToPlaceholder() {
        suggestionBox.text = suggestionBoxPlaceholder
        suggestionBox.textColor = UIColor.lightGrayColor()
    }

}

let suggestionBoxPlaceholder = "Enter your feedback for Williams Dining Services here."

extension ReviewsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == suggestionBoxPlaceholder {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        textView.becomeFirstResponder()
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            resetSuggestionBoxToPlaceholder()
        }
        textView.resignFirstResponder()
    }
}

extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Ratings"
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(selectedDiningHall)[pickerView.selectedRowInComponent(1)]
        return MenuHandler.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: selectedDiningHall).count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reviewTableViewCell") as! ReviewTableViewCell
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return cell
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(selectedDiningHall)[pickerView.selectedRowInComponent(1)]

        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: selectedDiningHall)[indexPath.row]

        cell.nameLabel.text = menuItem.name
        let rating = ReviewHandler.ratingForName(menuItem.name)
        if rating == noRating {
            cell.ratingControl.selectedSegmentIndex = cell.ratingControl.numberOfSegments - 1
        } else {
            cell.ratingControl.selectedSegmentIndex = rating - 1
        }

        return cell
    }
}

extension ReviewsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard component == 0 || component == 1 else {
            return 0
        }
        if component == 0 {
            return pickerDataSource.count
        } else {
            guard pickerDataSource != [.Error] && pickerDataSource != [] else {
                return 0
            }
            let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
            return MenuHandler.fetchMealTimes(selectedDiningHall).count
        }
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return pickerDataSource[row].stringValue()
        } else {
            guard pickerDataSource != [.Error] && pickerDataSource != [] else {
                return ""
            }
            let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
            return MenuHandler.fetchMealTimes(selectedDiningHall)[row].stringValue()
        }
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
        tableView.reloadData()
    }
}
