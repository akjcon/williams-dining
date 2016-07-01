//
//  ReviewTableViewCell.swift
//  williams-dining
//
//  Created by Nathan Andersen on 7/1/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation
import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ratingControl: UISegmentedControl!

    @IBAction func controlChanged(_ sender: UISegmentedControl) {
        let rating: Int
        if sender.selectedSegmentIndex == sender.numberOfSegments - 1 {
            rating = noRating
        } else {
            rating = sender.selectedSegmentIndex + 1
        }
        ReviewHandler.addRating(name: nameLabel.text!, rating: rating)
    }

}
