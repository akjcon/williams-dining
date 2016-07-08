//
//  DiningHallViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit


class DiningHallViewController: DefaultTableViewController {

    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    var pickerDataSource: [DiningHall] = [.Error]

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "FoodItemViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FoodItemViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default().addObserver(self, selector: #selector(DiningHallViewController.refreshTable), name: reloadDiningHallTableViewKey, object: nil)
        self.refreshView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default().removeObserver(self, name: reloadDiningHallTableViewKey, object: nil)
        self.refreshView()
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

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return ""
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let mealTimes: [MealTime] = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)
        guard mealTimes != [] else {
            return ""
        }
        return mealTimes[section].stringValue()
    }

    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        return MenuHandler.fetchMealTimes(diningHall: selectedDiningHall).count
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let mealTimes: [MealTime] = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)
        guard mealTimes != [] else {
            return 0
        }
        return MenuHandler.fetchByMealTimeAndDiningHall(mealTime: mealTimes[section], diningHall: selectedDiningHall).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemViewCell") as! FoodItemViewCell
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return cell
        }
        let section = indexPath.section
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let mealTimes: [MealTime] = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)
        guard mealTimes != [] else {
            return cell
        }
        let menuItem: CoreDataMenuItem = MenuHandler.fetchByMealTimeAndDiningHall(mealTime: mealTimes[section], diningHall: selectedDiningHall)[indexPath.row]
        cell.nameLabel.text = menuItem.name
        cell.glutenFreeLabel.isHidden = !menuItem.isGlutenFree
        cell.veganLabel.isHidden = !menuItem.isVegan

        if FavoritesHandler.isAFavoriteFood(name: menuItem.name) {
            cell.backgroundColor = Style.yellowColor
        } else {
            cell.backgroundColor = UIColor.clear()
        }

        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[indexPath.section]
        let menuItem: CoreDataMenuItem =
            MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall)[indexPath.row]
        if FavoritesHandler.isAFavoriteFood(name: menuItem.name) {
            FavoritesHandler.removeItemFromFavorites(name: menuItem.name)
        } else {
            FavoritesHandler.addItemToFavorites(name: menuItem.name)
        }
    }

}

extension DiningHallViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard pickerDataSource != [.Error] else {
            return 0
        }
        return pickerDataSource.count;
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return ""
        }
        return pickerDataSource[row].stringValue()
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        tableView.reloadData()
    }
}
