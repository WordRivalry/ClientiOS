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
            .overlay {
                if jitData.isFetching {
                    ProgressView()
                }
            }
            .onAppear {
                jitData.handleViewDidAppear()
            }
            .onDisappear {
                jitData.handleViewDidDisappear()
            }
             .handleNetworkChanges(
                onDisconnect: {
                 print("Disconnected from network.")
             }, onConnect: {
                 print("Connected to network.")
                 Task {
                     Logger.jitDataView.debug("Attempting to fetch data as the internet connection was detected.")
                     await self.jitData.fetchAndUpdateDataIfNeeded()
                     Logger.jitDataView.debug("Data fetched successfully.")
                 }
             })
            .logLifecycle(viewName: "JITDataView")
    }
    
    @ViewBuilder
    private var contentView: some View {
        if jitData.error != nil {
            Text("An error occured, please try later.")
        } else if jitData.isDataUnavailable() && !NetworkMonitoring.shared.isConnected {
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
    JITDataView(for: LeaderboardViewModel.preview) {
        LeaderboardLoadingView()
          
    } content: {
        VStack {
            Text("No update time.")
        }
    }
    .environment(Network()) // Is needed!
}
