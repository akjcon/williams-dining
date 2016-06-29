//
//  FavoritesViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class FavoritesViewController: PurpleStatusBarViewController {
    
    @IBOutlet var tableView: UITableView!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        NotificationCenter.default().addObserver(self, selector: #selector(FavoritesViewController.reloadTable), name: reloadFavoritesTableKey, object: nil)
    }

    func reloadTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
//        dispatch_async(dispatch_get_main_queue(), {self.tableView.reloadData()})
    }

    @IBAction func refreshButtonWasClicked(sender: AnyObject) {
        (UIApplication.shared().delegate as! AppDelegate).updateData()
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {

    /*
     UITableView functions
     */

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Style.primaryColor
        header.textLabel!.textColor = UIColor.yellow()
        header.alpha = 0.9
    }

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
