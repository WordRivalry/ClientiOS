//
//  NetworkUtility.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import Network
import OSLog


extension Notification.Name {
    static let didConnectToInternet = Notification.Name("didConnectToInternet")
    static let didDisconnectFromInternet = Notification.Name("didDisconnectToInternet")
}

class NetworkChecker {
    private var isMonitoring: Bool = false
    static let shared = NetworkChecker()
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isConnected: Bool = false
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        guard !isMonitoring else {
            Logger.network.info("Network monitoring is already active.")
            return
        }
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let strongSelf = self else { return }
            Task { @MainActor in
                strongSelf.updateConnectionStatus(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
        isMonitoring = true
        Logger.network.info("Network monitoring started.")
    }
    
    private func updateConnectionStatus(_ isConnectedNow: Bool) {
        self.isHealthy = true
        if isConnectedNow != isConnected {
            isConnected = isConnectedNow
            Logger.network.notice("Network status updated: \(self.isConnected ? "Connected" : "Disconnected")")
            NotificationCenter.default.post(
                name: isConnected ? .didConnectToInternet : .didDisconnectFromInternet,
                object: nil
            )
        }
    }
    
    public func stopMonitoring() {
        guard isMonitoring else {
            Logger.network.info("Network monitoring is not active.")
            return
        }
        
        monitor.cancel()
        isMonitoring = false
        self.isHealthy = false
        Logger.network.info("Network monitoring paused.")
    }
}


extension NetworkChecker: AppService {
    
    var identifier: String {
        "NetworkChecker"
    }
    
    var startPriority: ServiceStartPriority {
        .critical(0)
    }
    
    var isHealthy: Bool {
        get {
            self.isConnected
        }
        set {
            //
        }
    }
    
    func healthCheck() async -> Bool {
        self.isHealthy
    }
    
    func start() async -> String {
        self.startMonitoring()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        while self.isConnected == false {
            if GlobalOverlay.shared.overlay != .noInternet {
                Task { @MainActor in
                    GlobalOverlay.shared.overlay = .noInternet
                }
            }
            
            // Sleep for 1 sec before checking again
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        if GlobalOverlay.shared.overlay != .closed {
            Task { @MainActor in
                GlobalOverlay.shared.overlay = .closed
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        
        // Should already be up and running
        return "NetworkChecker has found a connection."
    }
    
    func handleAppBecomingActive() {
        self.startMonitoring()
    }
    
    func handleAppGoingInactive() {
        // Do nothing here
    }
    
    func handleAppInBackground() {
        self.stopMonitoring()
    }
}

