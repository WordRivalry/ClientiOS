//
//  NetworkUtility.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import Network

class NetworkChecker {
    static let shared = NetworkChecker()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
    }
    
    public func startMonitoring() {
        monitor.start(queue: queue)
    }
    
    public func cancelMonitoring() {
        monitor.cancel()
    }
}
