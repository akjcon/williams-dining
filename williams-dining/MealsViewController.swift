//
//  MealsViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

public class MealsViewController: DefaultTableViewController {

    var pickerDataSource: [MealTime] = [.Error]

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "FoodItemViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FoodItemViewCell")
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MealsViewController.refreshTable), name: reloadMealTableViewKey, object: nil)
        self.refreshView()
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: reloadMealTableViewKey, object: nil)
        self.refreshView()
    }

    func refreshTable() {
        dispatch_async(dispatch_get_main_queue(), {self.tableView.reloadData()})
/*        dispatch_async(dispatch_get_main_queue(), block: {
            self.tableView.reloadData()
        })*/
    }

    @IBAction func refreshButtonWasClicked(sender: UIBarButtonItem) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).updateData()
    }

    func refreshView() {
        pickerDataSource = MenuHandler.fetchMealTimes(nil)
        pickerView.selectRow(0, inComponent: 0, animated: true)

        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })


/*        dispatch_async(dispatch_get_main_queue(), block: {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })*/
    }
}

extension MealsViewController: UITableViewDataSource, UITableViewDelegate {

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return ""
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let diningHalls: [DiningHall] = MenuHandler.fetchDiningHalls(selectedMealTime)
        guard diningHalls != [] else {
            return ""
        }
        return diningHalls[section].stringValue()
    }

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRowInComponent(0)]
        return MenuHandler.fetchDiningHalls(selectedMealTime).count
    }


    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let diningHalls: [DiningHall] = MenuHandler.fetchDiningHalls(selectedMealTime)
        guard diningHalls != [] else {
            return 0
        }
        return MenuHandler.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: diningHalls[section]).count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let selectedMealTime = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemViewCell") as! FoodItemViewCell
        let diningHalls: [DiningHall] = MenuHandler.fetchDiningHalls(selectedMealTime)
        guard diningHalls != [] else {
            return cell
        }
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: diningHalls[section])[indexPath.row]

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
        // if in favorites, remove from favorites
        // if not in favorites, add to favorites
        let section = indexPath.section
        let selectedMealTime = pickerDataSource[pickerView.selectedRowInComponent(0)]
        let selectedDiningHall = MenuHandler.fetchDiningHalls(selectedMealTime)[section]
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(selectedMealTime, diningHall: selectedDiningHall)[indexPath.row]
        if FavoritesHandler.isAFavoriteFood(menuItem.name){
            FavoritesHandler.removeItemFromFavorites(menuItem.name)
        } else {
            FavoritesHandler.addItemToFavorites(menuItem.name)
        }
    }

}

extension MealsViewController: UIPickerViewDataSource, UIPickerViewDelegate {

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
        return pickerDataSource[row].stringValue()
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        tableView.reloadData()
    }
    
    
}
