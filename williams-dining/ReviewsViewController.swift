//
//  ReviewsViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 7/1/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class ReviewsViewController: DefaultTableViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickerView: UIPickerView!
    var pickerDataSource: [DiningHall] = [.Error]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.refreshView()
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

extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Ratings"
/*        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return ""
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let diningHalls: [DiningHall] = MenuHandler.fetchDiningHalls(mealTime: selectedMealTime)
        guard diningHalls != [] else {
            return ""
        }
        return diningHalls[section].stringValue()*/
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // sort this by course??
        return 1
/*        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedMealTime = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        return MenuHandler.fetchDiningHalls(mealTime: selectedMealTime).count*/
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return 0
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[pickerView.selectedRow(inComponent: 0)]

        return MenuHandler.fetchByMealTimeAndDiningHall(mealTime: selectedMealTime, diningHall: selectedDiningHall).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // have to figure out how to load a cell, what we want it to look like...

        let cell = UITableViewCell()

        guard pickerDataSource != [.Error] && pickerDataSource != [] else {
            return cell
        }
        let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
        let selectedMealTime = MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[pickerView.selectedRow(inComponent: 0)]


        return cell
    }

/*    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    }*/
}

extension ReviewsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard component == 0 || component == 1 else {
            return 0
        }
        if component == 0 {
            return pickerDataSource.count
        } else {
            guard pickerDataSource != [.Error] && pickerDataSource != [] else {
                return 0
            }
            let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
            return MenuHandler.fetchMealTimes(diningHall: selectedDiningHall).count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return pickerDataSource[row].stringValue()
        } else {
            guard pickerDataSource != [.Error] && pickerDataSource != [] else {
                return ""
            }
            let selectedDiningHall = pickerDataSource[pickerView.selectedRow(inComponent: 0)]
            return MenuHandler.fetchMealTimes(diningHall: selectedDiningHall)[row].stringValue()
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if component == 0 {
            pickerView.reloadComponent(1)
        } else if component == 1 {
            tableView.reloadData()
        }
    }
}
