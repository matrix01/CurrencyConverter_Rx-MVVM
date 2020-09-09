//
//  RequestProtocol.swift
//  Pay-Baymax
//
//  Created by milan.mia on 9/9/20.
//  Copyright © 2020 milan. All rights reserved.
//

import Foundation
import UIKit

enum ApiRequest {
    case list(parameters: list_get_params)
    case live(parameters: live_get_params)

    private var fullURL: String {
        return ApiServer.defaultApiUrl.appending(endPoint).removingPercentEncoding!
    }

    private var completeURL: URL {
        var reequestURL = URLComponents(string: fullURL)!
        switch self {
        case .list(let params):
            reequestURL.queryItems = [URLQueryItem(name: "access_key", value: params.access_key)]
        case .live(let params):
            reequestURL.queryItems = [URLQueryItem(name: "access_key", value: params.access_key),
                                      URLQueryItem(name: "source", value: params.source)]
        }

        guard let finalUrl = reequestURL.url else {
            fatalError("Unable to instantiate request uel")
        }
        return finalUrl
    }

    var endPoint: String {
        switch self {
        case .list: return "/list"
        case .live: return "/live"
        }
    }

    var userAgent: String {
        let projectName     = "Pay-Baymax"
        let buildNumber     = DeviceModel.bundleVersion
        let model           = UIDevice.current.model
        let systemVersion   = UIDevice.current.systemVersion
        let name            = UIDevice.current.name
        let scale           = UIScreen.main.scale
        let platform        = DeviceModel.platform

        return String(format: "%@/%@ (%@; iOS %@ %@; DeviceName/%@; Scale/%0.2f)",
                      projectName, buildNumber, model, systemVersion, platform, name, scale)
    }

    var request: URLRequest {
        var request = URLRequest(url: completeURL)

        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20000.0
        return request
    }
}

struct list_get_params: Codable {
    let access_key: String
}

struct live_get_params: Codable {
    let access_key: String

    // for which country to get conversion
    let source: String
}
