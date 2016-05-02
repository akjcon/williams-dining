//
//  MealsViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class MealsViewController: PurpleStatusBarViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    var pickerDataSource = MenuHandler.fetchMealTimes(nil)

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!
    var selectedMealTime: MealTime!

    var activeDiningHalls: [DiningHall]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        if pickerDataSource == [] {
            // we must be updating the data
            selectedMealTime = .Dinner
        } else {
            selectedMealTime = pickerDataSource[0]
        }
        activeDiningHalls = MenuHandler.fetchDiningHalls(selectedMealTime)
        tableView.reloadData()

        let nib = UINib(nibName: "FoodItemViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "FoodItemViewCell")


        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MealsViewController.refreshView), name: "reloadMealTable", object: nil)
    }

    func refreshView() {
        activeDiningHalls = MenuHandler.fetchDiningHalls(selectedMealTime)
        pickerDataSource = MenuHandler.fetchMealTimes(nil)
        selectedMealTime = pickerDataSource[0]
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })
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
        return MenuHandler.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: activeDiningHalls[section]).count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: activeDiningHalls[section])[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemViewCell") as! FoodItemViewCell
        cell.nameLabel.text = menuItem.name
        cell.glutenFreeLabel.hidden = !menuItem.isGlutenFree
        cell.veganLabel.hidden = !menuItem.isVegan
        if MenuHandler.isAFavoriteFood(menuItem.name) {
            cell.backgroundColor = Style.yellowColor
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }

        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if in favorites, remove from favorites
        // if not in favorites, add to favorites
        let section = indexPath.section
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: activeDiningHalls[section])[indexPath.row]
        if MenuHandler.isAFavoriteFood(menuItem.name){
            MenuHandler.removeItemFromFavorites(menuItem.name)
            // remove from favorites
        } else {
            // add to favorites
            MenuHandler.addItemToFavorites(menuItem.name)
        }
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
        activeDiningHalls = MenuHandler.fetchDiningHalls(selectedMealTime)
        tableView.reloadData()
    }
    
    
}