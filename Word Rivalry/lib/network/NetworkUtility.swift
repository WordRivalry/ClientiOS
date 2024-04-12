//
//  NetworkUtility.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import Network
import os.log


extension Notification.Name {
    static let didConnectToInternet = Notification.Name("didConnectToInternet")
    static let didDisconnectToInternet = Notification.Name("didDisconnectToInternet")
}

class NetworkChecker {
    static let shared = NetworkChecker()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let logger = Logger(subsystem: "Network", category: "NetworkChecker")
    
    var isConnected: Bool = false {
        didSet {
            if isConnected {
                Task { @MainActor in
                    self.logger.info("Connection status: \(self.isConnected)")
                    // Notify observers about the connectivity change.
                    NotificationCenter.default.post(name: .didConnectToInternet, object: nil)
                }
            } else {
                Task { @MainActor in
                    self.logger.info("Connection status: \(self.isConnected)")
                    // Notify observers about the connectivity change.
                    NotificationCenter.default.post(name: .didDisconnectToInternet, object: nil)
                }
            }
        }
    }
    
    private init() {
        monitor = NWPathMonitor()
        self.logger.info("*** NetworkChecker STARTED ***")
    }
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let strongSelf = self else { return }
            let isConnectedNow = path.status == .satisfied
            
            // Update isConnected only if there is a change in state to avoid redundant didSet calls
            if isConnectedNow != strongSelf.isConnected {
                strongSelf.isConnected = isConnectedNow
            }
        }
        monitor.start(queue: queue)
        
        self.logger.debug("Network monitoring started")
    }
    
    public func stopMonitoring() {
        monitor.cancel()
        self.logger.debug("Network monitoring paused")
    }
}

