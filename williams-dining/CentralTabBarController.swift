//
//  CentralTabBarController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 5/2/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class CentralTabBarController: UITabBarController {

    func displayLoadingError() {
        let alertController = UIAlertController(title: "Data Error", message: "Loading the menus timed out.\n\nPlease reload the data.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Destructive) {
            (action) in
            self.selectedIndex = 2
        })
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
