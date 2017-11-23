//
// Created by Sergiy Dubovik on 23/11/2017.
// Copyright (c) 2017 Sergiy Dubovik. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

typealias NewLocationDiscoveredCallback = (CLLocationCoordinate2D) -> Void

protocol NewLocationDiscoveredDelegate: NSObjectProtocol {
    func newLocationDiscovered(_ coord: CLLocationCoordinate2D)
}

class SimpleLocationManager: NSObject, CLLocationManagerDelegate {
    var locationDiscoveredCallback: NewLocationDiscoveredDelegate? {
        willSet {
            resetLastReportedLocation()
        }
    }

    private let locationManager = CLLocationManager()
    private(set) var lastReportedLocation: CLLocationCoordinate2D?

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if (needToRequestWhenInUseAuthorization()) {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.startUpdatingLocation()
        print("location")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got \(locations.count) new locations \(locations[0].horizontalAccuracy), \(locations[0].coordinate.latitude), \(locations[0].coordinate.longitude)")
        let newLocation = SimpleLocationManager.getCoordinate(location: locations[0])

        if (locationDiscoveredCallback != nil) {
            if (lastReportedLocation == nil || SimpleLocationManager.areNotEqual(lastReportedLocation!, newLocation)) {
                locationDiscoveredCallback!.newLocationDiscovered(newLocation)
                lastReportedLocation = newLocation
            }
        }
    }

    static private func getCoordinate(location: CLLocation) -> CLLocationCoordinate2D {
        if (ProcessInfo.processInfo.arguments.contains("test")) {
            // London, for repeatability
            return CLLocationCoordinate2D(latitude: 51.50998, longitude: -0.1337)
        }
        return location.coordinate
    }

    static private func areEqual(_ c1: CLLocationCoordinate2D, _ c2: CLLocationCoordinate2D) -> Bool {
        return c1.longitude == c2.longitude && c1.latitude == c2.latitude
    }

    static private func areNotEqual(_ c1: CLLocationCoordinate2D, _ c2: CLLocationCoordinate2D) -> Bool {
        return !areEqual(c1, c2)
    }

    private func resetLastReportedLocation() {
        lastReportedLocation = nil
    }

    private func needToRequestWhenInUseAuthorization() -> Bool {
        if #available(iOS 8.0, *) {
            return CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse
        }

        return false
    }
}
