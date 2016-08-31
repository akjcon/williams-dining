//
//  FavoritesViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

public class FavoritesViewController: DefaultTableViewController {
    
    @IBOutlet var tableView: UITableView!

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavoritesViewController.reloadTable), name: reloadFavoritesTableKey, object: nil)
        self.reloadTable()
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: reloadFavoritesTableKey, object: nil)
        self.reloadTable()
    }

    func reloadTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {

    /*
     UITableView functions
     */

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Favorites"
    }

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesHandler.getFavorites().count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favorites = FavoritesHandler.getFavorites()
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesTableViewCell") as! FavoritesTableViewCell
        cell.nameLabel.text = favorites[indexPath.row]
        return cell;
    }

    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let favorite = FavoritesHandler.getFavorites()[indexPath.row]
            FavoritesHandler.removeItemFromFavorites(favorite)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }

    }


}
