//
//  FoursquareServiceTests.swift
//  nearByTests
//
//  Created by Sergiy Dubovik on 28/11/2017.
//  Copyright © 2017 Sergiy Dubovik. All rights reserved.
//

import XCTest
import CoreLocation
@testable import nearBy

class RestApiMock: RestApi {
    public var url: String?
    public var onCompletion: ((JSON, Error?) -> Void)?

    override func makeRestGetRequest(url: String, onCompletion: @escaping (JSON, Error?) -> Void) -> URLSessionTask {
        self.url = url
        self.onCompletion = onCompletion
        return URLSessionTask()
    }
}

class FoursquareServiceTests: XCTestCase {
    private let creds = FoursquareCredentails(plistFullPath: Bundle(for: FoursquareServiceTests.self).path(forResource: "testcredentials", ofType: "plist")!)
    private var restApiMock: RestApiMock!
    private var service: FoursquareService!

    override func setUp() {
        super.setUp()

        restApiMock = RestApiMock()
        service = FoursquareService(creds, restApiMock)
    }

    func testExploreUrl() {
        service.explore(coord: CLLocationCoordinate2D(latitude: 1.23, longitude: 1.45), onCompleted: nilCallback)
        XCTAssertEqual("https://api.foursquare.com/v2/venues/explore?ll=1.23,1.45&client_id=client_test_id&client_secret=client_test_secret&v=20171124&limit=20", restApiMock.url)
    }

    func testSearchUrl() {
        service.searchVenue(coord: CLLocationCoordinate2D(latitude: 1.23, longitude: 1.45), query: "pizza double", onCompleted: nilCallback)
        XCTAssertEqual("https://api.foursquare.com/v2/venues/search?ll=1.23,1.45&client_id=client_test_id&client_secret=client_test_secret&query=pizza%20double&v=20171124&limit=20", restApiMock.url)
    }

    private func nilCallback(json: JSON, error: Error?) {
    }
}
