//
//  FoursquareCredentialTests.swift
//  nearByTests
//
//  Created by Sergiy Dubovik on 28/11/2017.
//  Copyright © 2017 Sergiy Dubovik. All rights reserved.
//

import XCTest
@testable import nearBy

class FoursquareCredentialTests: XCTestCase {
    func testLoadFromPlist() {
        let fullPath = Bundle(for: type(of: self)).path(forResource: "testcredentials", ofType: "plist")
        let creds = FoursquareCredentails(plistFullPath: fullPath!)
        XCTAssertEqual("client_test_id", creds.clientId)
        XCTAssertEqual("client_test_secret", creds.clientSecret)
    }
}
