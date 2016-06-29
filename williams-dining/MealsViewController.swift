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

    var pickerDataSource = MenuHandler.fetchMealTimes(diningHall: nil)

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.reloadData()

        if pickerDataSource == [] {
            // temp placeholder
            pickerDataSource = [.Dinner]
        }


        let nib = UINib(nibName: "FoodItemViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FoodItemViewCell")


//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MealsViewController.refreshView), name: "reloadMealTable", object: nil)

        NotificationCenter.default().addObserver(self, selector: #selector(MealsViewController.refreshTable), name: reloadMealTableViewKey, object: nil)
    }

    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
/*        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })*/
    }

    func refreshView() {
        pickerDataSource = MenuHandler.fetchMealTimes(diningHall: nil)
        pickerView.selectRow(0, inComponent: 0, animated: true)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })

/*        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })*/
    }

    /*
     UITableView functions
     */

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Style.primaryColor
        header.textLabel!.textColor = UIColor.yellow() //make the text white
        header.alpha = 0.9 //make the header transparent
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        return MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)[section].stringValue()
    }

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        return MenuHandler.fetchDiningHalls(mealTime: selectedMealTime).count
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedDiningHall = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)[section]
        return MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedDiningHall = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)[section]
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall)[indexPath.row]


        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemViewCell") as! FoodItemViewCell
        cell.nameLabel.text = menuItem.name
        cell.glutenFreeLabel.isHidden = !menuItem.isGlutenFree
        cell.veganLabel.isHidden = !menuItem.isVegan
        if MenuHandler.isAFavoriteFood(name: menuItem.name) {
            cell.backgroundColor = Style.yellowColor
        } else {
            cell.backgroundColor = UIColor.clear()
        }

        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        // if in favorites, remove from favorites
        // if not in favorites, add to favorites
        let section = indexPath.section
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedDiningHall = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)[section]
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall)[indexPath.row]
        if MenuHandler.isAFavoriteFood(name: menuItem.name){
            MenuHandler.removeItemFromFavorites(name: menuItem.name)
            // remove from favorites
        } else {
            // add to favorites
            MenuHandler.addItemToFavorites(name: menuItem.name)
        }
    }

    /*
     UIPickerView functions
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row].stringValue()
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        tableView.reloadData()
    }
    
    
}
