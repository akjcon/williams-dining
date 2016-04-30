//
//  DiningHallViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class DiningHallViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    var pickerDataSource = MenuHandler.fetchActiveDiningHalls()

    var selectedDiningHall: DiningHall!

    var activeMealTimes: [MealTime]!

    var menuItems: [MealTime:[CoreDataMenuItem]]!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self

        selectedDiningHall = pickerDataSource[0]
        fetchData()
        let view = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,20))
        view.backgroundColor = Style.primaryColor
        self.view.addSubview(view)

        let nib = UINib(nibName: "FoodItemViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "FoodItemViewCell")

    }

    func fetchData() {
        menuItems = [MealTime:[CoreDataMenuItem]]()

        activeMealTimes = MenuHandler.fetchMealTimesForDiningHall(selectedDiningHall)

        for mealTime in activeMealTimes {
            let mealItems = MenuHandler.fetchByMealTimeAndDiningHall(mealTime, diningHall: selectedDiningHall)

            menuItems[mealTime] = mealItems
        }

        tableView.reloadData()
    }

    /*
     UITableView functions
    */

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Style.primaryColor
        header.textLabel!.textColor = UIColor.yellowColor()
        header.alpha = 0.9
    }


    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return activeMealTimes[section].stringValue()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return activeMealTimes.count
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[activeMealTimes[section]]!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let menuItem: CoreDataMenuItem = menuItems[activeMealTimes[section]]![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemViewCell") as! FoodItemViewCell
        cell.nameLabel.text = menuItem.name
        cell.glutenFreeLabel.hidden = !menuItem.isGlutenFree
        cell.veganLabel.hidden = !menuItem.isVegan
        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if in favorites, remove from favorites
        // if not in favorites, add to favorites

        

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
        return pickerDataSource[row].stringValue()
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedDiningHall = pickerDataSource[row]
        fetchData()
    }


}