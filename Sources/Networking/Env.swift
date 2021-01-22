//
//  Environment.swift
//  Example-iOS
//
//  Created by Vasilis Panagiotopoulos on 15/9/20.
//  Copyright © 2020 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation
import TermiNetwork

enum Env: EnvironmentProtocol {
    case dev
    case qa
    case uat
    case production

    func configure() -> Environment {
        switch self {
            case .dev:
                return Environment(scheme: .http, host: "localhost", port: 3000, configuration: configuration)
            case .qa:
                return Environment(scheme: .http, host: "10.0.0.10")
            case .uat:
                return Environment(scheme: .https, host: "132.168.0.13")
            case .production:
                return Environment(scheme: .https, host: "liveserver.com", suffix: .path(["v1"]))
        }
    }

    private var configuration: Configuration {
        let conf = Configuration()

        // Enable debug mode
        conf.verbose = true

        // Set JSON as default param encode type
        conf.requestBodyType = .JSON

        return conf
    }
}
