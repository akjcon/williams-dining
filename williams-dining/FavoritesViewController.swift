//
//  FavoritesViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class FavoritesViewController: DefaultTableViewController {
    
    @IBOutlet var tableView: UITableView!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default().addObserver(self, selector: #selector(FavoritesViewController.reloadTable), name: reloadFavoritesTableKey, object: nil)
        self.reloadTable()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default().removeObserver(self, name: reloadFavoritesTableKey, object: nil)
        self.reloadTable()
    }

    func reloadTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }

    @IBAction func refreshButtonWasClicked(sender: AnyObject) {
        (UIApplication.shared().delegate as! AppDelegate).updateData()
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {

    /*
     UITableView functions
     */

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Favorites"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuHandler.getFavorites().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favorites = MenuHandler.getFavorites()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesTableViewCell") as! FavoritesTableViewCell
        cell.nameLabel.text = favorites[indexPath.row]
        return cell;
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let favorite = MenuHandler.getFavorites()[indexPath.row]
            MenuHandler.removeItemFromFavorites(name: favorite)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }

    }


}
