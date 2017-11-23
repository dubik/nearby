//
//  nearByUITests.swift
//  nearByUITests
//
//  Created by Sergiy Dubovik on 23/11/2017.
//  Copyright © 2017 Sergiy Dubovik. All rights reserved.
//

import XCTest

class nearByUITests: XCTestCase {
        var app: XCUIApplication!
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("test")
        app.launch()
    }
    
    func testInitialApplicationLaunchDownloadsVenuesAround() {
        let tablesQuery = app.tables
        _ = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Picturehouse Central"]/*[[".cells.staticTexts[\"Picturehouse Central\"]",".staticTexts[\"Picturehouse Central\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 5)
        XCTAssertTrue(tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Prince of Wales Theatre"]/*[[".cells.staticTexts[\"Prince of Wales Theatre\"]",".staticTexts[\"Prince of Wales Theatre\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        XCTAssertEqual(20, tablesQuery.cells.count)
    }
    
    func testSearchForPizza() {
        let tablesQuery = app.tables
        let searchSearchField = app.searchFields["Search"]
        searchSearchField.tap()
        searchSearchField.typeText("pizza")
        _ = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Pizza 4 feuilles"]/*[[".cells.staticTexts[\"Pizza 4 feuilles\"]",".staticTexts[\"Pizza 4 feuilles\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 5)
        XCTAssertTrue(tablesQuery.staticTexts["Pizza Hut"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["PizzaExpress"].exists)
    }
    
    func testSearchForSushiButCancel() {
        let tablesQuery = app.tables
        tablesQuery.searchFields["Search"].tap()
        app.searchFields["Search"].typeText("sushi")
        _ = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Shaftsbury Ave"]/*[[".cells.staticTexts[\"Shaftsbury Ave\"]",".staticTexts[\"Shaftsbury Ave\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 5)
        app.buttons["Cancel"].tap()
        _ = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Picturehouse Central"]/*[[".cells.staticTexts[\"Picturehouse Central\"]",".staticTexts[\"Picturehouse Central\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 5)
        XCTAssertTrue(tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Prince of Wales Theatre"]/*[[".cells.staticTexts[\"Prince of Wales Theatre\"]",".staticTexts[\"Prince of Wales Theatre\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
    }
}
