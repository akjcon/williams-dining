//
//  MealsViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class MealsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {


    var pickerDataSource = MealTime.allCases
//    var pickerDataSource = foodDictionary.getActiveMealTimes()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!
    var selectedMealTime: MealTime = .Breakfast

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    /*
     UITableView functions
     */

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys = foodDictionary.getDiningHallsForMealTime(selectedMealTime)
        if keys == nil {
            print("not a valid case")
        } else {
            return String(keys![section])
        }
        return ""
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let keys = foodDictionary.getDiningHallsForMealTime(selectedMealTime)
        if keys == nil {
            print("not a valid case")
        } else {
            return keys!.count
        }
        return 0
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = foodDictionary.getMealMenu(selectedMealTime)
        if dict == nil {
            print("invalid selection")
        } else {
            let keys = foodDictionary.getDiningHallsForMealTime(selectedMealTime)
            if keys == nil {
                print("not a valid case")
            } else {
                let selectedKey = keys![section]
                return dict![selectedKey]!.count
            }
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        var menuItem: MenuItem = MenuItem()
        let dict = foodDictionary.getMealMenu(selectedMealTime)
        if dict == nil {
            print("invalid selection")
        } else {
            let keys = foodDictionary.getDiningHallsForMealTime(selectedMealTime)
            if keys == nil {
                print("not a valid case")
            } else {
                let selectedKey = keys![section]
                menuItem = dict![selectedKey]![indexPath.row]
            }
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("DiningHallTableCell") as! FoodTableViewCell
        if menuItem.diningHall != .Error {
            cell.titleLabel.text = menuItem.food
        }
        return cell;
    }


    /*
     UIPickerView functions
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerDataSource[row])
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedMealTime = pickerDataSource[row]
        tableView.reloadData()
    }
    
    
}