//
//  TitleLabel.swift
//  williams-dining
//
//  Created by Nathan Andersen on 2/16/17.
//  Copyright © 2017 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class TitleLabel: UILabel {

    private func sharedInit() {
        self.textColor = Style.secondaryColor
        self.backgroundColor = Style.defaultColor
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
