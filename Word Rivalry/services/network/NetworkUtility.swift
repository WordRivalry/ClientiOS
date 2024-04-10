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
              }
          }
    }
    
    private init() {
        monitor = NWPathMonitor()
        self.logger.info("*** NetworkChecker STARTED ***")
    }
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
        
        self.logger.debug("Network monitoring started")
    }
    
    public func stopMonitoring() {
        monitor.cancel()
        self.logger.debug("Network monitoring paused")
    }
}

