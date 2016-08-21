//
//  DiningHallViewControllerTests.swift
//  williams-dining
//
//  Created by Nathan Andersen on 8/15/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import XCTest
@testable import williams_dining

class DiningHallViewControllerTests: XCTestCase {

    var viewController: DiningHallViewController!
    
    override func setUp() {
        super.setUp()
        // set the MOC to the MOCK MOC, haha

        MockMenuCache.initializeMockData()
        print(MenuHandler.fetchDiningHalls(mealTime: nil, moc: MockMenuCache.mockManagedObjectContext))

        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiningHallViewController") as! DiningHallViewController

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testVCHasWhitmansDisplayed() {
        let _ = viewController.view
        viewController.refreshView()
        print(viewController.pickerDataSource)
        viewController.pickerView.selectRow(viewController.pickerDataSource.index(of: DiningHall.Whitmans)!, inComponent: 0, animated: false)
        // select Whitmans

        // this seems like a UI test though. ah well, have to get lunch.
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
