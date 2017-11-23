//
//  VenuesPresenter.swift
//  nearBy
//
//  Created by Sergiy Dubovik on 28/11/2017.
//  Copyright © 2017 Sergiy Dubovik. All rights reserved.
//

import Foundation
import CoreLocation

protocol VenuesView: NSObjectProtocol {
    func showError(message: String)
    func reloadData()
    func isSearchActive() -> Bool
    func getSearchBarText() -> String?
}

class VenuesPresenter: NSObject, NewLocationDiscoveredDelegate {
    private var locationManager: SimpleLocationManager!
    private var foursquareService: FoursquareService!
    private var view: VenuesView?

    private var model: [JSON]?
    private var filteredModel: [JSON]?

    private var searchForVenuesWithQueryTrigger: DelayedSelector!
    private var searchVenueTask: URLSessionTask!

    init(locationManager: SimpleLocationManager, foursquareService: FoursquareService) {
        super.init()

        self.locationManager = locationManager
        self.foursquareService = foursquareService

        locationManager.locationDiscoveredCallback = self
        searchForVenuesWithQueryTrigger = DelayedSelector(timeInterval: 2, target: self, selector: #selector(searchForVenues))
    }

    deinit {
        searchVenueTask?.cancel()
    }

    func attachView(view: VenuesView) {
        self.view = view
    }

    func newLocationDiscovered(_ coord: CLLocationCoordinate2D) {
        foursquareService.explore(coord: coord, onCompleted: handleExploreResults)
    }

    private func handleExploreResults(json: JSON, error: Error?) {
        updateModelWithJsonResponse(modelRef: &model, responseParser: VenuesPresenter.getModelFromExploreResponse,
                json: json, error: error)
    }

    private func handleVenuesSearchResults(response json: JSON, error: Error!) {
        updateModelWithJsonResponse(modelRef: &filteredModel, responseParser: VenuesPresenter.getVenuesFromSearchResponse,
                json: json, error: error)
    }

    private func updateModelWithJsonResponse(modelRef: inout [JSON]?, responseParser: (JSON) -> [JSON], json: JSON, error: Error?) {
        if (error == nil) {
            let venues = responseParser(json)
            modelRef = VenuesPresenter.sortByDistance(venues: venues)
            reloadDataAsync()
        } else {
            showErrorAsync(message: "Can't get list of venues due to an error, try later")
        }
    }

    func updateSearchResults(_ searchText: String?) {
        if (searchText != nil && searchText!.isEmpty) {
            filteredModel = nil
            reloadDataAsync()
        } else {
            searchForVenuesWithQueryTrigger.start()
        }
    }

    @objc func searchForVenues() {
        searchVenueTask?.cancel()
        let query = view?.getSearchBarText()
        if (query != nil && !query!.isEmpty) {
            searchVenueTask = searchForVenuesAsync(with: query)
        }
    }

    private func searchForVenuesAsync(with query: String?) -> URLSessionTask {
        return foursquareService.searchVenue(coord: locationManager.lastReportedLocation!, query: query!, onCompleted: handleVenuesSearchResults)
    }

    private func reloadDataAsync() {
        DispatchQueue.main.async {
            self.view?.reloadData()
        }
    }

    private func showErrorAsync(message: String) {
        DispatchQueue.main.async {
            self.view?.showError(message: message)
        }
    }

    func getModel() -> [JSON]! {
        if (view!.isSearchActive() && filteredModel != nil) {
            return filteredModel
        } else {
            return model
        }
    }

    static private func getModelFromExploreResponse(foursquareResponse: JSON) -> [JSON] {
        // Explore call doesn't return array of venues, instead it returns array of items which contain a venue
        // so we extract venue from item and put it into array with 'map'
        let json0 = foursquareResponse["response"]
        let json1 = json0["groups"]
        let json2 = json1[0]["items"]
        return json2.arrayValue.map({ $0["venue"] })
    }

    static private func getVenuesFromSearchResponse(foursquareResponse: JSON) -> [JSON] {
        return foursquareResponse["response"]["venues"].arrayValue
    }

    static private func sortByDistance(venues: [JSON]) -> [JSON] {
        return venues.sorted(by: { (x, y) in
            return x["location"]["distance"].intValue < y["location"]["distance"].intValue
        })
    }
}