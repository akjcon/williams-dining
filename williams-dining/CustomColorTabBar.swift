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
        self.barTintColor = Style.defaultColor
        self.tintColor = Style.secondaryColor

        // do a rudimentary calculation on if the default color is too light
        // and if so, set the 'unselected' to either black or white
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
