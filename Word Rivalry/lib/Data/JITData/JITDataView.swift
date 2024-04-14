//
//  DataView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI
import Combine
import OSLog

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the JIT Data events from the app
    static let jitDataView = Logger(subsystem: subsystem, category: "JITDataView")
}

struct JITDataView<Service: JITData, LoadingView: View, Content: View>: View {
    @Environment(Network.self) private var network: Network
    let jitData: JITData
    let loadingView: () -> LoadingView
    let content: () -> Content
    
    init(for jitData: JITData, loadingView: @escaping () -> LoadingView, content: @escaping () -> Content) {
        self.jitData = jitData
        self.loadingView = loadingView
        self.content = content
    }
    
    var body: some View {
        contentView
            .onAppear {
                jitData.handleViewDidAppear()
            }
            .onDisappear {
                jitData.handleViewDidDisappear()
            }
            .onChange(of: network.isConnected) { oldValue, newValue in
                if oldValue == false && newValue == true {
                    Task {
                        Logger.jitDataView.debug("Attempting to fetch data as the internet connection was detected.")
                        await self.jitData.fetchData()
                        Logger.jitDataView.debug("Data fetched successfully.")
                    }
                }
            }
            .logLifecycle(viewName: "JITDataView")
    }
    
    @ViewBuilder
    private var contentView: some View {
        if jitData.isDataUnavailable() && network.isDisconnected {
            VStack {
                Spacer()
                InternetStatusMessageView(message: "No available data")
                Spacer()
                BasicDismiss()
            }
        } else if jitData.isDataUnavailable() {
            loadingView()
        } else {
            content()
        }
    }
    
    @ViewBuilder
    private var noConnectionView: some View {
        Text("No internet connection and no cached data.")
    }
    
    @ViewBuilder
    private var lastUpdatedView: some View {
        Group {
            if let lastUpdate = jitData.lastUpdateTime {
                Text("Last updated: \(lastUpdate.formatted())")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}


#Preview {
    JITDataView(for: JITLeaderboard.preview) {
        LeaderboardLoadingView()
          
    } content: {
        VStack {
            Text("No update time.")
        }
    }
    .environment(Network()) // Is needed!
}
