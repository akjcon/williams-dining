//
//  PurpleStatusBarViewController.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import UIKit

class PurpleStatusBarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let frame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main().bounds.size.width, height: 20)
        let view = UIView(frame: frame)
        view.backgroundColor = Style.purpleColor
        self.view.addSubview(view)
    }
}
