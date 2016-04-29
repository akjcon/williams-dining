//
//  DiningHallViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class DiningHallViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    var pickerDataSource = foodDictionary.getActiveDiningHalls()

    var selectedDiningHall: DiningHall!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self

        selectedDiningHall = pickerDataSource[0]
        let view = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,20))
        view.backgroundColor = Style.primaryColor
        self.view.addSubview(view)
    }

    /*
     UITableView functions
    */

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Style.primaryColor
        header.textLabel!.textColor = UIColor.yellowColor()
        header.alpha = 0.9
    }


    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys = foodDictionary.getMealTimesForDiningHall(selectedDiningHall)
        if keys == nil {
            print("not a valid case")
        } else {
            return keys![section].stringValue()
        }
        return ""
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let keys = foodDictionary.getMealTimesForDiningHall(selectedDiningHall)
        if keys == nil {
            print("not a valid case")
        } else {
            return keys!.count
        }
        return 0
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict = foodDictionary.getDiningHallMenu(selectedDiningHall)
        if dict == nil {
            print("invalid selection")
        } else {
            let keys = foodDictionary.getMealTimesForDiningHall(selectedDiningHall)
            if keys == nil {
                print("not a valid case")
            } else {
                let selectedKey = keys![section]
                return dict![selectedKey]!.count
            }
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        var menuItem: MenuItem = MenuItem()
        let dict = foodDictionary.getDiningHallMenu(selectedDiningHall)
        if dict == nil {
            print("invalid selection")
        } else {
            let keys = foodDictionary.getMealTimesForDiningHall(selectedDiningHall)
            if keys == nil {
                print("not a valid case")
            } else {
                let selectedKey = keys![section]
                menuItem = dict![selectedKey]![indexPath.row]
            }
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("DiningHallTableCell") as! FoodTableViewCell
        if menuItem.diningHall != .Error {
            cell.titleLabel.text = menuItem.food
        }
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
        selectedDiningHall = pickerDataSource[row]
        tableView.reloadData()
    }


}