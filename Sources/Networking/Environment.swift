//
//  Environment.swift
//  Example-iOS
//
//  Created by Vasilis Panagiotopoulos on 15/9/20.
//  Copyright © 2020 Ryo Aoyama. All rights reserved.
//

import Foundation
import TermiNetwork

enum Environment: TNEnvironmentProtocol {
    case dev
    case qa
    case uat
    case production

    func configure() -> TNEnvironment {
        switch self {
            case .dev:
                return TNEnvironment(scheme: .http, host: "localhost", port: 3000, configuration: configuration)
            case .qa:
                return TNEnvironment(scheme: .http, host: "10.0.0.10")
            case .uat:
                return TNEnvironment(scheme: .https, host: "132.168.0.13")
            case .production:
                return TNEnvironment(scheme: .https, host: "liveserver.com", suffix: .path(["v1"]))
        }
    }

    private var configuration: TNConfiguration {
        let conf = TNConfiguration()

        // Enable debug mode
        conf.verbose = true

        // Set JSON as default param encode type
        conf.requestBodyType = .JSON

        // Use mock data
        if let mockDataPath = Bundle.main.path(forResource: "MockData", ofType: "bundle") {
            conf.mockDataBundle = Bundle.init(path: mockDataPath)
            conf.useMockData = true
        }
        return conf
    }
}
