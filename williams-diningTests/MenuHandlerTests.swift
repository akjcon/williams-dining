//
//  MenuHandlerTests.swift
//  williams-dining
//
//  Created by Nathan Andersen on 8/20/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import XCTest
@testable import williams_dining

class MenuHandlerTests: XCTestCase {

    override func setUp() {
        super.setUp()

//        MockMenuCache.initializeMockData()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testWhitmansParse() {
        // determine an individual completion
        let validate = {
            (item: MenuItem) in
            print(item)
        }
        let finished = {
            () in
//            print("finished")
            XCTAssertTrue(true)
        }
        if let path = Bundle.main().pathForResource("Whitmans", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.dataReadingMappedIfSafe)
                if let jsonResult: AnyObject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) {
                    MenuHandler.parseMenu(menu: jsonResult, diningHall: .Whitmans, individualCompletion: validate, completionHandler: finished)
                }
                // finish this up
            } catch let error as NSError {
                print(error.localizedDescription)
            } catch {
                print("uh oh")
            }
        } else {
            print("invalid filename / path")
        }

    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
