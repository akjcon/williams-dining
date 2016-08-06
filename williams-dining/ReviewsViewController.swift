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
        self.layer.borderColor = tintColor.cgColor
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default().addObserver(self, selector: #selector(ReviewsViewController.keyboardWillBeShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(ReviewsViewController.keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.refreshView()
        setSubmitButtonTitle(title: "Submit")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.refreshView()
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        setSubmitButtonTitle(title: "Submit")
    }

    func refreshView() {
        pickerDataSource = MenuHandler.fetchDiningHalls(mealTime: nil)
        pickerView.selectRow(0, inComponent: 0, animated: true)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })
    }

    @IBAction func userDidTapOutsideTextArea(_ sender: UITapGestureRecognizer) {
        if suggestionBox.isFirstResponder() {
            suggestionBox.resignFirstResponder()
        }
        setSubmitButtonTitle(title: "Submit")
    }

    func setSubmitButtonTitle(title: String) {
        submitButton.setTitle(title, for: [])
    }

    func keyboardWillBeShown(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue() {
            self.view.window!.frame.origin.y = -1 * keyboardSize.height
        }
    }

    func keyboardWillBeHidden(notification: Notification) {
        self.view.window!.frame = UIScreen.main().bounds
    }

    @IBAction func submitReviews() {

        submitButton.isUserInteractionEnabled = false
        submitButton.isSelected = true

        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[pickerView.selectedRow(inComponent: 1)]

        ReviewHandler.submitReviews(diningHall: selectedDiningHall, mealTime: selectedMealTime, suggestion: suggestionBox.text) {
            (userProvidedFeedback: Bool, serverError: Bool) in
            self.submitButton.isUserInteractionEnabled = true
            self.submitButton.isSelected = false

            self.displayErrorMessage(title: self.comingSoonTitle, body: self.comingSoonBody)

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
            alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            alertController?.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        } else {
            alertController?.title = title
            alertController?.message = body
        }
        self.present(alertController!, animated: true, completion: nil)
    }

    func resetSuggestionBoxToPlaceholder() {
        suggestionBox.text = suggestionBoxPlaceholder
        suggestionBox.textColor = UIColor.lightGray()
    }

}

let suggestionBoxPlaceholder = "Enter your feedback for Williams Dining Services here."

extension ReviewsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == suggestionBoxPlaceholder {
            textView.text = ""
            textView.textColor = UIColor.black()
        }
        textView.becomeFirstResponder()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            resetSuggestionBoxToPlaceholder()
        }
        textView.resignFirstResponder()
    }
}

extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Ratings"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[pickerView.selectedRow(inComponent: 1)]
        return MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewTableViewCell") as! ReviewTableViewCell
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return cell
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[pickerView.selectedRow(inComponent: 1)]

        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall)[indexPath.row]

        cell.nameLabel.text = menuItem.name
        let rating = ReviewHandler.ratingForName(name: menuItem.name)
        if rating == noRating {
            cell.ratingControl.selectedSegmentIndex = cell.ratingControl.numberOfSegments - 1
        } else {
            cell.ratingControl.selectedSegmentIndex = rating - 1
        }

        return cell
    }
}

extension ReviewsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard component == 0 || component == 1 else {
            return 0
        }
        if component == 0 {
            return pickerDataSource.count
        } else {
            guard pickerDataSource != [.Error] && pickerDataSource != [] else {
                return 0
            }
            let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
            return MenuHandler.fetchMealTimes(diningHall: selectedDiningHall).count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return pickerDataSource[row].stringValue()
        } else {
            guard pickerDataSource != [.Error] && pickerDataSource != [] else {
                return ""
            }
            let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
            return MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[row].stringValue()
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
        tableView.reloadData()
    }
}
