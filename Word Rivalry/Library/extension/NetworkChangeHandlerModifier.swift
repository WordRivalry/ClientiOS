//
//  NetworkChangeHandler.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import SwiftUI

struct NetworkChangeHandlerModifier: ViewModifier {
    @Environment(Network.self) private var network: Network
    var onDisconnect: (() -> Void)?
    var onConnect: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onChange(of: network.isConnected) { oldValue, newValue in
                if oldValue && !newValue {
                    onDisconnect?()
                } else if !oldValue && newValue {
                    onConnect?()
                }
            }
    }
}

extension View {
    func handleNetworkChanges(onDisconnect: (() -> Void)? = nil, onConnect: (() -> Void)? = nil) -> some View {
        self.modifier(NetworkChangeHandlerModifier(onDisconnect: onDisconnect, onConnect: onConnect))
    }
}

