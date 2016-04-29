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

    @IBOutlet var tableView: UITableView!
    
    var pickerDataSource = DiningHall.allCases

    var tableDataSource: [MenuItem] = diningHallMenus[.Driscoll]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }






    /*
     UITableView functions
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiningHallTableCell") as! FoodTableViewCell
        cell.titleLabel.text = tableDataSource[indexPath.row].food
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
        return pickerDataSource[row].getStringValue()
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        tableDataSource = diningHallMenus[DiningHall.allCases[row]]!
        tableView.reloadData()
    }


}