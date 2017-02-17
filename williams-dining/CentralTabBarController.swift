
//
//  CentralTabBarController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 5/2/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

public class CentralTabBarController: UITabBarController {

    private func sharedInit() {
        self.tabBar.backgroundColor = Style.defaultColor
        self.tabBar.tintColor = Style.secondaryColor
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.sharedInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    /*
    func displayLoadingError() {
        let alertController = UIAlertController(title: "Data Error", message: "There was an error while loading menus.\n\nPlease try again."/*Loading the menus timed out.\n\nPlease reload the data."*/, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .destructive) {
            (action) in
            self.selectedIndex = 2
        })
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            if let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            // topController should now be your topmost view controller
            topController.present(alertController, animated: true, completion: nil)
        }


//        self.presentedViewController?.present(alertController, animated: true, completion: nil)

//        self.present(alertController, animated: true, completion: nil)
    }*/
}
