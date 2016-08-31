//
//  DefaultTableViewHeaderImplementer.swift
//  williams-dining
//
//  Created by Nathan Andersen on 7/1/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

public class DefaultTableViewController: PurpleStatusBarViewController {

    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Style.purpleColor
        header.textLabel!.textColor = UIColor.yellowColor()
        header.alpha = 0.9
    }
}
