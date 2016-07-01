//
//  ReviewHandler.swift
//  williams-dining
//
//  Created by Nathan Andersen on 7/1/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation

let noRating = -1

class ReviewHandler {

    private static var ratings: [String:Int] = [String:Int]()

    internal static func addRating(name: String, rating: Int) {
        ratings[name] = rating
    }

    internal static func removeRating(name: String) {
        ratings.removeValue(forKey: name)
    }

    internal static func clearRatings() {
        ratings = [String:Int]()
    }

    internal static func ratingForName(name: String) -> Int {
        if let rating = ratings[name] {
            return rating
        } else {
            return noRating
        }
    }

    internal static func submitReviews(suggestion: String) {
        for key in ratings.keys {
            print(key)
            print(ratings[key]!)
        }

        clearRatings()
    }

}
