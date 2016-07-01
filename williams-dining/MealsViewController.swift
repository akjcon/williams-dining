//
//  MealsViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class MealsViewController: DefaultTableViewController {

//    var pickerDataSource = MenuHandler.fetchMealTimes(diningHall: nil)
    var pickerDataSource: [MealTime] = [.Error]

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "FoodItemViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FoodItemViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default().addObserver(self, selector: #selector(MealsViewController.refreshTable), name: reloadMealTableViewKey, object: nil)
        self.refreshView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default().removeObserver(self, name: reloadMealTableViewKey, object: nil)
        self.refreshView()
    }

    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    func refreshView() {
        pickerDataSource = MenuHandler.fetchMealTimes(diningHall: nil)
        pickerView.selectRow(0, inComponent: 0, animated: true)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })
    }
}

extension MealsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return ""
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let diningHalls: [DiningHall] = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)
        guard diningHalls != [] else {
            return ""
        }
        return diningHalls[section].stringValue()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        return MenuHandler.fetchDiningHalls(mealTime: selectedMealTime).count
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let diningHalls: [DiningHall] = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)
        guard diningHalls != [] else {
            return 0
        }
        return MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: diningHalls[section]).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemViewCell") as! FoodItemViewCell
        let diningHalls: [DiningHall] = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)
        guard diningHalls != [] else {
            return cell
        }
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: diningHalls[section])[indexPath.row]

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

}

extension MealsViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row].stringValue()
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        tableView.reloadData()
    }
    
    
}
