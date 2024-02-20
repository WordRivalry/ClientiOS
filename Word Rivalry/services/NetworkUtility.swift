//
//  NetworkUtility.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import Network

class NetworkUtility {
    static let shared = NetworkUtility()

    private init() {}

    /// Checks if the internet is available.
    /// - Returns: A `Bool` indicating internet availability.
    func isInternetAvailable() async -> Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")

        return await withCheckedContinuation { continuation in
            monitor.pathUpdateHandler = { path in
                continuation.resume(returning: path.status == .satisfied)
                monitor.cancel()
            }

            monitor.start(queue: queue)
        }
    }
}
