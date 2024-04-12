//
//  InternetRequiredViewModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import Foundation
import Combine
import SwiftUI
import OSLog


extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the network events from the app
    static let network = Logger(subsystem: subsystem, category: "network")
}

@Observable class Network {
    var isConnected: Bool = true
    var isDisconnected: Bool = false
    
    @ObservationIgnored
    private var connectCancellable: AnyCancellable?
    
    @ObservationIgnored
    private var disconnectCancellable: AnyCancellable?
    
    init() {
        subscribeToInternetConnectionEvents()
        subscribeToInternetDeconnectionEvents()
        let isConnected = NetworkChecker.shared.isConnected
    }
    
    deinit {
        connectCancellable?.cancel()
        disconnectCancellable?.cancel()
    }
    
    private func subscribeToInternetConnectionEvents() {
        connectCancellable?.cancel() // Cancel for safety
        connectCancellable = NotificationCenter.default.publisher(for: .didConnectToInternet)
            .receive(on: DispatchQueue.main)  // Ensure UI updates are on the main thread
            .sink { _ in
                Task { @MainActor in
                    Logger.network.debug("Network found.")
                    withAnimation(.easeInOut) {
                        self.isConnected = true
                        self.isDisconnected = !self.isConnected
                    }
                }
            }
    }
    
    private func subscribeToInternetDeconnectionEvents() {
        disconnectCancellable?.cancel() // Cancel for safety
        disconnectCancellable = NotificationCenter.default.publisher(for: .didDisconnectToInternet)
            .receive(on: DispatchQueue.main)  // Ensure UI updates are on the main thread
            .sink { _ in
                Task { @MainActor in
                    // Log that we are attempting to fetch data
                    Logger.network.debug("Network lost.")
                    withAnimation(.easeInOut) {
                        self.isConnected = false
                        self.isDisconnected = !self.isConnected
                    }
                }
            }
    }
}
