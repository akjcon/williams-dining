//
//  PurpleStatusBarViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import Foundation
import UIKit

class PurpleStatusBarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let view = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,20))
        view.backgroundColor = Style.primaryColor
        self.view.addSubview(view)

    }

}