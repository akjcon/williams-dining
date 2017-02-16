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
        tableView.register(nib, forCellReuseIdentifier: "FoodItemViewCell")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(MealsViewController.refreshTable), name: reloadMealTableViewKey, object: nil)
        self.refreshView()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: reloadMealTableViewKey, object: nil)
        self.refreshView()
    }

    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    @IBAction func refreshButtonWasClicked(_ sender: UIBarButtonItem) {
        (UIApplication.shared.delegate as! AppDelegate).updateData()
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

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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

    public func numberOfSections(in tableView: UITableView) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        return MenuHandler.fetchDiningHalls(mealTime: selectedMealTime).count
    }


    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemViewCell") as! FoodItemViewCell
        let diningHalls: [DiningHall] = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)
        guard diningHalls != [] else {
            return cell
        }
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: diningHalls[section])[indexPath.row]

//        cell.nameLabel.setText(text: menuItem.name)
        cell.nameLabel.text = menuItem.name
        cell.glutenFreeLabel.isHidden = !menuItem.isGlutenFree
        cell.veganLabel.isHidden = !menuItem.isVegan
        if FavoritesHandler.isAFavoriteFood(name: menuItem.name) {
            cell.backgroundColor = Style.yellowColor
        } else {
            cell.backgroundColor = UIColor.clear
        }

        return cell;
    }

    public func tableView(_
        tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if in favorites, remove from favorites
        // if not in favorites, add to favorites
        let section = indexPath.section
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedDiningHall = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)[section]
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall)[indexPath.row]
        if FavoritesHandler.isAFavoriteFood(name: menuItem.name){
            FavoritesHandler.removeItemFromFavorites(name: menuItem.name)
        } else {
            FavoritesHandler.addItemToFavorites(name: menuItem.name)
        }
    }

}

extension MealsViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard pickerDataSource != [.Error] else {
            return 0
        }
        return pickerDataSource.count;
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row].stringValue()
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        tableView.reloadData()
    }
    
    
}
