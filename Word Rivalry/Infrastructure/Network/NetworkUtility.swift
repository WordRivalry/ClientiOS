//
//  NetworkUtility.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import Network
import OSLog

/// Extension to define custom notification names related to network connectivity.
extension Notification.Name {
    // Notification for when the device connects to the internet.
    static let didConnectToInternet = Notification.Name("didConnectToInternet")
    // Notification for when the device disconnects from the internet.
    static let didDisconnectFromInternet = Notification.Name("didDisconnectToInternet")
}

/// Class to monitor network connectivity throughout the app.
@Observable class NetworkMonitoring {
    /// Flag to indicate if monitoring has started to prevent multiple starts.
    private var isMonitoring: Bool = false
    
    /// Singleton instance to allow global access to network status.
    static let shared = NetworkMonitoring()
    
    /// NWPathMonitor instance to observe changes in network paths.
    private let monitor: NWPathMonitor
    
    /// Queue on which network changes will be reported.
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    /// Publicly accessible property to check if the device is currently connected to the internet.
    var isConnected: Bool = false
    
    /// Private initializer to setup the network monitor and ensure singleton usage.
    private init() {
        monitor = NWPathMonitor()
    }
    
    /// Starts monitoring the network status changes if not already monitoring.
    public func startMonitoring() {
        guard !isMonitoring else {
            // Logging attempt to start monitoring when it's already active.
            Logger.network.info("Network monitoring is already active.")
            return
        }
        
        // Setting the path update handler to handle changes in network connectivity.
        monitor.pathUpdateHandler = { [weak self] path in
            guard let strongSelf = self else { return }
            Task { @MainActor in
                // Update the connection status based on network path's status.
                strongSelf.updateConnectionStatus(path.status == .satisfied)
            }
        }
        // Starting the monitoring on the defined queue.
        monitor.start(queue: queue)
        isMonitoring = true
        // Logging the start of network monitoring.
        Logger.network.info("Network monitoring started.")
    }
    
    /// Updates the `isConnected` property and posts notifications on change.
    /// - Parameter isConnectedNow: The current network connection status.
    private func updateConnectionStatus(_ isConnectedNow: Bool) {
        // Check if the new status is different from the previous one.
        if isConnectedNow != isConnected {
            isConnected = isConnectedNow
            // Logging the change in network status.
            Logger.network.notice("Network status updated: \(self.isConnected ? "Connected" : "Disconnected")")
            // Posting a notification about the change in network status.
            NotificationCenter.default.post(
                name: isConnected ? .didConnectToInternet : .didDisconnectFromInternet,
                object: nil
            )
        }
    }
    
    /// Stops monitoring network status changes if currently monitoring.
    public func stopMonitoring() {
        guard isMonitoring else {
            // Logging attempt to stop monitoring when it's not active.
            Logger.network.info("Network monitoring is not active.")
            return
        }
        
        // Cancelling the network path monitor.
        monitor.cancel()
        isMonitoring = false
        // Logging the pause of network monitoring.
        Logger.network.info("Network monitoring paused.")
    }
}
