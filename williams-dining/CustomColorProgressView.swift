//
//  CustomColorProgressView.swift
//  williams-dining
//
//  Created by Nathan Andersen on 2/17/17.
//  Copyright © 2017 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class CustomColorProgressView: UIProgressView {

    private func sharedInit() {
        self.progressTintColor = Style.defaultColor
        self.trackTintColor = Style.secondaryColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

}
