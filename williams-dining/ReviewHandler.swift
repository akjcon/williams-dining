//
//  ReviewHandler.swift
//  williams-dining
//
//  Created by Nathan Andersen on 7/1/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import Foundation

let noRating = -1
let httpGet = "GET"
let httpPost = "POST"

public class ReviewHandler {

    private static let baseUrl = "http://dining.stage.williams.edu/gravityformsapi"
    private static let valueHeaderKey = "input_values"
    private static let diningHallKey = "dining_hall"
    private static let mealTimeKey = "meal_time"
    private static let fieldId = 1
    private static let formId = 20
    private static let session = URLSession.shared()

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
        ratings.keys.forEach({reviewStr += $0 + ":" + String(ratings[$0]!) + "***"})

        if suggestion != suggestionBoxPlaceholder && suggestion != "" {
            reviewStr += "General feedback:" + suggestion
        }

        guard reviewStr != "" else {
            completion(userProvidedFeedback: false, serverError: false)
            return
        }

        reviewStr = diningHall.stringValue() + "***" + mealTime.stringValue() + "***" + reviewStr
        submitReviewString(reviewStr: reviewStr) {
            (result: Bool) in
            completion(userProvidedFeedback: true,serverError: result)
        }


    }

    private static func submitReviewString(reviewStr: String, completionHandler: (Bool) -> ()) {
        print(reviewStr)

        let url = baseUrl + "/forms"
//        let url = baseUrl + "/forms/" + String(formId) + "/submissions"
//        print(url)
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = httpGet
//        urlRequest.httpMethod = httpPost
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let fieldHeader = "input_" + String(fieldId)
        let dataToSubmit = [fieldHeader:reviewStr]
        // can build this out as custom later
        urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: dataToSubmit, options: [])

        let task = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) in
            guard error == nil else {
                print(error)
                print("There was an actual error, seen above ^.")
                completionHandler(true)
                return
            }
            guard (response as! HTTPURLResponse).statusCode == 200 else {
                print("The following status code is no good.")
                print((response as! HTTPURLResponse).statusCode)
                completionHandler(true)
                return
            }

            if let jsonObject: AnyObject = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) {
                print(jsonObject)
                print("object finished")
                completionHandler(false)
            } else {
                print("Couldn't handle the data...")
                completionHandler(true)
            }
        })
        task.resume()
    }

}
