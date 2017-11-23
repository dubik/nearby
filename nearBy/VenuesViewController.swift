//
//  NearByViewController.swift
//  nearBy
//
//  Created by Sergiy Dubovik on 23/11/2017.
//  Copyright © 2017 Sergiy Dubovik. All rights reserved.
//

import Foundation
import UIKit

import Dispatch

class VenuesViewController: UITableViewController {
    private let searchController = UISearchController(searchResultsController: nil)

    private let presenter = VenuesPresenter(locationManager: SimpleLocationManager(),
            foursquareService: FoursquareService(FoursquareCredentails(plistFullPath: Bundle.main.path(forResource: "credentials", ofType: "plist")!)))



    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.attachView(view: self)
        tableView.register(UINib(nibName: "Detailed", bundle: nil), forCellReuseIdentifier: "detailedCell")

        configureSearchController()
    }

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let x = presenter.getModel() {
            return x.count
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = presenter.getModel()!
        let venue = model[indexPath.row]
        let name = venue["name"].stringValue
        let address = venue["location"]["address"].stringValue
        let distance = venue["location"]["distance"].intValue

        let cell = tableView.dequeueReusableCell(withIdentifier: "detailedCell") as! Detailed
        cell.name.text = name
        cell.address.text = address
        cell.distance.text = VenuesViewController.formatDistance(inMeters: distance)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = Bundle.main.loadNibNamed("Detailed", owner: self, options: nil)?.first as! Detailed
        return cell.bounds.height
    }

    static private func formatDistance(inMeters: Int) -> String {
        if (inMeters > 1000) {
            let inKm = Float(inMeters) / 1000.0
            return String(format: "%0.1f km", inKm)
        }

        return "\(inMeters) m"
    }
}

extension VenuesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        presenter.updateSearchResults(searchText)
    }
}

extension VenuesViewController: VenuesView {
    func reloadData() {
        tableView.reloadData()
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true)
    }

    func isSearchActive() -> Bool {
        return searchController.isActive
    }

    func getSearchBarText() -> String? {
        return searchController.searchBar.text
    }
}
