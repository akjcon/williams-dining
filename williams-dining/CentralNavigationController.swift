//
//  CentralNavigationController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 5/2/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class CentralNavigationController: UINavigationController {
    
    let loadingViewController: LoadingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoadingViewController") as! LoadingViewController
    let mainViewController: CentralTabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainViewController") as! CentralTabBarController

    func displayLoadingScreen() {
        loadingViewController.initializeLabelTimer()
        self.pushViewController(loadingViewController, animated: true)
    }

    func hideLoadingScreen() {
        loadingViewController.stopTimer()
        self.popViewControllerAnimated(true)
    }

    func hideLoadingScreenWithError() {
        loadingViewController.stopTimer()
        self.popViewControllerAnimated(true)

//        mainViewController.displayLoadingError()
        mainViewController.selectedIndex = 2
        
    }

}
