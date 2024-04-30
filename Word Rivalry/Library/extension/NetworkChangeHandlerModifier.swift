//
//  NetworkChangeHandler.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import SwiftUI

/// A SwiftUI ViewModifier to handle changes in network connectivity within views.
struct NetworkChangeHandlerModifier: ViewModifier {
    // Optional closures to be executed when the network disconnects or connects.
    var onDisconnect: (() -> Void)?
    var onConnect: (() -> Void)?

    /// Modifies the content view to react to changes in network connectivity.
    ///
    /// - Parameter content: The original view that will be modified by this modifier.
    /// - Returns: Some View wrapped with functionality to monitor and react to network status changes.
    func body(content: Content) -> some View {
        content
            // Observes changes in the `isConnected` property of the network monitor.
            .onChange(of: NetworkMonitoring.shared.isConnected) { oldValue, newValue in
                // Executes the `onDisconnect` closure if the network status changes from connected to disconnected.
                if oldValue && !newValue {
                    onDisconnect?()
                }
                // Executes the `onConnect` closure if the network status changes from disconnected to connected.
                else if !oldValue && newValue {
                    onConnect?()
                }
            }
    }
}

extension View {
    /// A method to enhance any SwiftUI view with network change handling capabilities.
    ///
    /// This method applies a modifier to the view that listens for network connectivity changes
    /// and executes specified closures based on the network status changes.
    ///
    /// - Parameters:
    ///   - onDisconnect: An optional closure that fires when the network connection is lost.
    ///   - onConnect: An optional closure that fires when the network connection is established.
    /// - Returns: The view modified to handle network changes by executing provided closures.
    ///
    /// Usage Example:
    /// ```swift
    /// Text("Check Network Connection")
    ///     .handleNetworkChanges(onDisconnect: {
    ///         print("Disconnected from network.")
    ///     }, onConnect: {
    ///         print("Connected to network.")
    ///     })
    /// ```
    func handleNetworkChanges(onDisconnect: (() -> Void)? = nil, onConnect: (() -> Void)? = nil) -> some View {
        // Applies the `NetworkChangeHandlerModifier` with specified behaviors for connection and disconnection events.
        self.modifier(NetworkChangeHandlerModifier(onDisconnect: onDisconnect, onConnect: onConnect))
    }
}



