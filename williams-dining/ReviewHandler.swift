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

    internal static func submitReviews(diningHall: DiningHall, mealTime: MealTime, suggestion: String, completion: (userProvidedFeedback: Bool, serverError: Bool) -> ()) {
        var reviewStr = ""

        for key in ratings.keys {
            reviewStr += key + ":" + String(ratings[key]!) + "***"
        }

        if suggestion != suggestionBoxPlaceholder && suggestion != "" {
            reviewStr += "General feedback:" + suggestion
        }

        if reviewStr != "" {
            reviewStr = diningHall.stringValue() + "***" + mealTime.stringValue() + "***" + reviewStr
            submitReviewString(reviewStr: reviewStr) {
                (result: Bool) in
                completion(userProvidedFeedback: true,serverError: result)
            }
        } else {
            completion(userProvidedFeedback: false,serverError: false)
        }
    }

    private static func submitReviewString(reviewStr: String, completionHandler: (Bool) -> ()) {
        print(reviewStr)
        completionHandler(false)
    }

}
