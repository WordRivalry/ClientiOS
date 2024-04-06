//
//  NetworkUtility.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import Network
import os.log

class NetworkChecker {
    static let shared = NetworkChecker()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let logger = Logger(subsystem: "com.WordRivalry", category: "NetworkChecker")
    
    private(set) var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        self.logger.info("*** NetworkChecker STARTED ***")
    }
    
    public func startMonitoring() {
        monitor.start(queue: queue)
        self.logger.debug("Network monitoring started")
    }
    
    public func cancelMonitoring() {
        monitor.cancel()
        self.logger.debug("Network monitoring paused")
    }
}
