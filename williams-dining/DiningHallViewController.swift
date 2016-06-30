//
//  DiningHallViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit


class DiningHallViewController: PurpleStatusBarViewController {

    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    var pickerDataSource = MenuHandler.fetchDiningHalls(mealTime: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self

        if pickerDataSource == [] {
            // temp placeholder
            pickerDataSource = [.Driscoll]
        }
        tableView.reloadData()

        let nib = UINib(nibName: "FoodItemViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FoodItemViewCell")

        NotificationCenter.default().addObserver(self, selector: #selector(DiningHallViewController.refreshTable), name: reloadDiningHallTableViewKey, object: nil)
    }


    func refreshTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    func refreshView() {
        pickerDataSource = MenuHandler.fetchDiningHalls(mealTime: nil)
        pickerView.selectRow(0, inComponent: 0, animated: true)
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.pickerView.reloadAllComponents()
        })
    }

}

extension DiningHallViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Style.primaryColor
        header.textLabel!.textColor = UIColor.yellow()
        header.alpha = 0.9
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let mealTimes: [MealTime] = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)
        guard mealTimes != [] else {
            return ""
        }
        return mealTimes[section].stringValue()
    }

    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        return MenuHandler.fetchMealTimes(diningHall: selectedDiningHall).count
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let mealTimes: [MealTime] = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)
        guard mealTimes != [] else {
            return 0
        }
        return MenuHandler.fetchByMealTimeAndDiningHall(mealTime: mealTimes[section], diningHall: selectedDiningHall).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[section]
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if in favorites, remove from favorites
        // if not in favorites, add to favorites
        let section = indexPath.section
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[section]
        let menuItem: CoreDataMenuItem =
            MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall)[indexPath.row]
        if MenuHandler.isAFavoriteFood(name: menuItem.name){
            MenuHandler.removeItemFromFavorites(name: menuItem.name)
            // remove from favorites
        } else {
            // add to favorites
            MenuHandler.addItemToFavorites(name: menuItem.name)
        }
    }

}

extension DiningHallViewController: UIPickerViewDelegate, UIPickerViewDataSource {

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
