//
//  VenuesPresenterTests.swift
//  nearByTests
//
//  Created by Sergiy Dubovik on 28/11/2017.
//  Copyright © 2017 Sergiy Dubovik. All rights reserved.
//

import XCTest
import CoreLocation
@testable import nearBy

class MockView: NSObject, VenuesView {
    var reloadDataCalled = false

    func showError(message: String) {
    }

    func reloadData() {
        reloadDataCalled = true
    }

    func isSearchActive() -> Bool {
        return false
    }

    func getSearchBarText() -> String? {
        fatalError("getSearchBarText() has not been implemented")
    }
}

class VenuesPresenterTests: XCTestCase {
    let locationManager = SimpleLocationManager()
    let creds = FoursquareCredentails(plistFullPath: Bundle(for: FoursquareServiceTests.self).path(forResource: "testcredentials", ofType: "plist")!)

    private var view: MockView!
    private var reloadedPredicate: NSPredicate! // This is for waiting when reloadedData was called since it's called from dispatch queue
    private var restApiMock: RestApiMock!
    private var service: FoursquareService!
    private var presenter: VenuesPresenter!

    override func setUp() {
        super.setUp()

        view = MockView()
        reloadedPredicate = NSPredicate { [view] _, _ in
            view!.reloadDataCalled
        }

        restApiMock = RestApiMock()
        service = FoursquareService(creds, restApiMock)
        presenter = VenuesPresenter(locationManager: locationManager, foursquareService: service)
        presenter.attachView(view: view)
    }

    static private func loadJsonFromBundle(name: String) -> String {
        let exploreResponseFullPath = Bundle(for: VenuesPresenterTests.self).path(forResource: name, ofType: "json")!
        do {
            return try String(contentsOfFile: exploreResponseFullPath)
        } catch {
            XCTFail("Can't load test data")
            return ""
        }
    }

    func testNewPlaceDiscoveredFlow() {
        // Trigger presenter logic via newLocationDiscovered, then reply with json

        let coord = CLLocationCoordinate2D(latitude: 1.23, longitude: 1.45)
        presenter.newLocationDiscovered(coord) // Triggering new location...

        // Make sure presenter made good rest call
        XCTAssertEqual("https://api.foursquare.com/v2/venues/explore?ll=1.23,1.45&client_id=client_test_id&client_secret=client_test_secret&v=20171124&limit=20", restApiMock.url)

        // Simulate response with prerecorded json
        let jsonResponse = VenuesPresenterTests.loadJsonFromBundle(name: "testExplore")
        restApiMock.onCompletion!(JSON(parseJSON: jsonResponse), nil) // Replying with json simulating server response
        waitForReloadDataAsyncCall()

        XCTAssertTrue(view.reloadDataCalled)
        XCTAssertEqual(20, presenter.getModel().count)
    }

    private func waitForReloadDataAsyncCall() {
        // Reload data will be called
        expectation(for: reloadedPredicate, evaluatedWith: [:], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
}
