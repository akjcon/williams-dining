//
//  RefreshButton.swift
//  williams-dining
//
//  Created by Nathan Andersen on 2/17/17.
//  Copyright © 2017 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class RefreshButton: UIBarButtonItem {
    private func sharedInit() {
        self.tintColor = Style.secondaryColor
    }

    override init() {
        super.init()
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
}
