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

    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var suggestionBox: UITextView!
    var pickerDataSource: [DiningHall] = [.Error]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default().addObserver(self, selector: #selector(ReviewsViewController.keyboardWillBeShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(ReviewsViewController.keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.refreshView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.refreshView()
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    }

    func keyboardWillBeShown(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue() {
            self.view.window!.frame.origin.y = -1 * keyboardSize.height
        }
    }

    func keyboardWillBeHidden(notification: Notification) {
        self.view.window!.frame = UIScreen.main().bounds
    }

}

let placeholder = "Enter your feedback for Williams Dining Services here."

extension ReviewsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = UIColor.black()
        }
        textView.becomeFirstResponder()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray()
        }
        textView.resignFirstResponder()
    }
}

extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Ratings"
/*        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return ""
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let diningHalls: [DiningHall] = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)
        guard diningHalls != [] else {
            return ""
        }
        return diningHalls[section].stringValue()*/
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // sort this by course??
        return 1
/*        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        return MenuHandler.fetchDiningHalls(mealTime: selectedMealTime).count*/
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[pickerView.selectedRow(inComponent: 0)]

        return MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // have to figure out how to load a cell, what we want it to look like...

        let cell = UITableViewCell()

        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return cell
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[pickerView.selectedRow(inComponent: 0)]


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
        } else if component == 1 {
            tableView.reloadData()
        }
    }
}
