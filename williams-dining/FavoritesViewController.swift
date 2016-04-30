//
//  FavoritesViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class FavoritesViewController: PurpleStatusBarViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var notificationSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        return "Favorites"
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuHandler.getFavorites().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favorites = MenuHandler.getFavorites()
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesTableViewCell") as! FavoritesTableViewCell
        cell.nameLabel.text = favorites[indexPath.row]
        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // if in favorites, remove from favorites
        // if not in favorites, add to favorites
        
        
        
    }

}