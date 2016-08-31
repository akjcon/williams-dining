//
//  DiningHallViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

//var diningHallVCIdentifier = "DiningHallViewController"

public class DiningHallViewController: DefaultTableViewController {

    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    var pickerDataSource: [DiningHall] = [.Error]

    override public func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "FoodItemViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "FoodItemViewCell")
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DiningHallViewController.refreshTable), name: reloadDiningHallTableViewKey, object: nil)
        self.refreshView()
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: reloadDiningHallTableViewKey, object: nil)
        self.refreshView()
    }

    @IBAction func refreshButtonWasClicked(sender: UIBarButtonItem) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).updateData()
    }

    func refreshTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

    func refreshView() {
        pickerDataSource = MenuHandler.fetchDiningHalls(nil)
        pickerView.selectRow(0, inComponent: 0, animated: true)
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })
    }
}

extension DiningHallViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return ""
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let mealTimes: [MealTime] = MenuHandler.fetchMealTimes(selectedDiningHall)
        guard mealTimes != [] else {
            return ""
        }
        return mealTimes[section].stringValue()
    }

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
        return MenuHandler.fetchMealTimes(selectedDiningHall).count
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let mealTimes: [MealTime] = MenuHandler.fetchMealTimes(selectedDiningHall)
        guard mealTimes != [] else {
            return 0
        }
        return MenuHandler.fetchByMealTimeAndDiningHall(mealTimes[section], diningHall: selectedDiningHall).count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemViewCell") as! FoodItemViewCell
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return cell
        }
        let section = indexPath.section
        let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let mealTimes: [MealTime] = MenuHandler.fetchMealTimes(selectedDiningHall)
        guard mealTimes != [] else {
            return cell
        }
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(mealTimes[section], diningHall: selectedDiningHall)[indexPath.row]


        (cell.nameLabel as! MarqueeLabel).type = .LeftRight
        cell.nameLabel.text = menuItem.name
        cell.glutenFreeLabel.hidden = !menuItem.isGlutenFree
        cell.veganLabel.hidden = !menuItem.isVegan

        if FavoritesHandler.isAFavoriteFood(menuItem.name) {
            cell.backgroundColor = Style.yellowColor
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }

        return cell;
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedDiningHall = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(selectedDiningHall)[indexPath.section]
        let menuItem: CoreDataMenuItem =
            MenuHandler.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: selectedDiningHall)[indexPath.row]
        if FavoritesHandler.isAFavoriteFood(menuItem.name) {
            FavoritesHandler.removeItemFromFavorites(menuItem.name)
        } else {
            FavoritesHandler.addItemToFavorites(menuItem.name)
        }
    }

}

extension DiningHallViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard pickerDataSource != [.Error] else {
            return 0
        }
        return pickerDataSource.count;
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return ""
        }
        return pickerDataSource[row].stringValue()
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        tableView.reloadData()
    }
}
