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

    var pickerDataSource = MenuReader.fetchActiveMealTimes()

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!
    var selectedMealTime: MealTime!

    var activeDiningHalls: [DiningHall]!
    var menuItems: [DiningHall:[CoreDataMenuItem]]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        selectedMealTime = pickerDataSource[0]
        fetchData()
        let view = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,20))
        view.backgroundColor = Style.primaryColor
        self.view.addSubview(view)
    }

    func fetchData() {
        menuItems = [DiningHall:[CoreDataMenuItem]]()
        // cache this?

        activeDiningHalls =
            MenuReader.fetchDiningHallsForMealTime(selectedMealTime)

        for diningHall in activeDiningHalls {
            let mealItems = MenuReader.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: diningHall)

            menuItems[diningHall] = mealItems
        }
        
        tableView.reloadData()
    }

    /*
     UITableView functions
     */

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Style.primaryColor
        header.textLabel!.textColor = UIColor.yellowColor() //make the text white
        header.alpha = 0.9 //make the header transparent
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return activeDiningHalls[section].stringValue()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return activeDiningHalls.count
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[activeDiningHalls[section]]!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let menuItem = menuItems[activeDiningHalls[section]]![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("DiningHallTableCell") as! FoodTableViewCell
        cell.titleLabel.text = menuItem.name
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
        return pickerDataSource[row].stringValue()
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedMealTime = pickerDataSource[row]
        fetchData()
    }
    
    
}