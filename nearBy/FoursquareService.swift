//
// Created by Sergiy Dubovik on 24/11/2017.
// Copyright (c) 2017 Sergiy Dubovik. All rights reserved.
//

import Foundation
import CoreLocation

// Makes http requests and returns JSON via callbacks
public class RestApi {
    func makeRestGetRequest(url: String, onCompletion: @escaping (JSON, Error?) -> Void) -> URLSessionTask {
        print(url)
        let ur = URL(string: url)
        let req = URLRequest(url: ur!)

        let task = URLSession.shared.dataTask(with: req, completionHandler: { data, resp, err in
            onCompletion(JSON(data!), err)
        })
        task.resume()
        return task
    }
}

public class FoursquareCredentails {
    public private(set) var clientId: String
    public private(set) var clientSecret: String

    public init(plistFullPath: String) {
        let dict = FoursquareCredentails.loadDictionaryFromPlist(fileName: plistFullPath)

        clientId = dict.value(forKey: "CLIENT_ID") as! String
        clientSecret = dict.value(forKey: "CLIENT_SECRET") as! String
    }

    static private func loadDictionaryFromPlist(fileName: String) -> NSDictionary {
        let url = URL(fileURLWithPath: fileName)
        return NSDictionary(contentsOf: url)!
    }
}

public class FoursquareService: NSObject {
    let url = "https://api.foursquare.com/v2/venues/"
    private var credentials: FoursquareCredentails
    private var restApi: RestApi

    init(_ credentials: FoursquareCredentails, _ restApi: RestApi = RestApi()) {
        self.credentials = credentials
        self.restApi = restApi
    }

    @discardableResult
    func explore(coord: CLLocationCoordinate2D, onCompleted: @escaping (JSON, Error?) -> Void) -> URLSessionTask {
        let query = "\(url)explore?\(formatCoord(coord: coord))&\(formatCredentials())&v=\(formatVersion())&\(formatLimit())"
        let task = restApi.makeRestGetRequest(url: query, onCompletion: onCompleted)
        return task
    }

    @discardableResult
    func searchVenue(coord: CLLocationCoordinate2D, query: String, onCompleted: @escaping (JSON, Error?) -> Void) -> URLSessionTask {
        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let query = "\(url)search?\(formatCoord(coord: coord))&\(formatCredentials())&query=\(escapedQuery)&v=\(formatVersion())&\(formatLimit())"
        let task = restApi.makeRestGetRequest(url: query, onCompletion: onCompleted)
        return task
    }

    private func formatCredentials() -> String {
        return "client_id=\(credentials.clientId)&client_secret=\(credentials.clientSecret)"
    }

    private func formatCoord(coord: CLLocationCoordinate2D) -> String {
        return "ll=\(coord.latitude),\(coord.longitude)"
    }

    private func formatVersion() -> String {
        return "20171124"
    }

    private func formatLimit() -> String {
        return "limit=20"
    }
}
