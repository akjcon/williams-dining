//
//  FoodItemViewCell.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/30/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class FoodItemViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var veganLabel: UILabel!
    @IBOutlet var glutenFreeLabel: UILabel!

/*    private func sharedInit() {
        self.veganLabel?.backgroundColor = Style.defaultColor
        self.glutenFreeLabel?.backgroundColor = Style.defaultColor

        self.veganLabel.textColor = Style.secondaryColor
        self.glutenFreeLabel.textColor = Style.secondaryColor
    }*/

    internal func drawColors() {
        self.veganLabel.backgroundColor = Style.defaultColor
        self.glutenFreeLabel.backgroundColor = Style.defaultColor


        self.veganLabel.textColor = Style.secondaryColor
        self.glutenFreeLabel.textColor = Style.secondaryColor

    }

    /*
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        print("initd")
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("what")
        self.sharedInit()
    }*/


}
