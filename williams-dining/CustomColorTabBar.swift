//
//  CustomColorTabBar.swift
//  williams-dining
//
//  Created by Nathan Andersen on 2/16/17.
//  Copyright © 2017 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class CustomColorTabBar: UITabBar {

    private func sharedInit() {
        self.tintColor = Style.secondaryColor
        self.backgroundColor = Style.defaultColor

        print("initted")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

}
