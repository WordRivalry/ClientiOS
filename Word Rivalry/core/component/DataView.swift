//
//  DataView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI

struct DataView<Service: DataService, LoadingView: View, Content: View>: View {
    let dataService: DataService
    let loadingView: () -> LoadingView
    let content: () -> Content

    var body: some View {
        VStack {
            contentView
        }
            .onAppear {
                dataService.handleViewDidAppear()
            }
            .onDisappear {
                dataService.handleViewDidDisappear()
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if !dataService.isDataAvailable() && !NetworkChecker.shared.isConnected {
            noConnectionView
        } else if !dataService.isDataAvailable()  {
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
            if let lastUpdate = dataService.lastUpdateTime {
                Text("Last updated: \(lastUpdate.formatted())")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}


#Preview {
    DataView(dataService: LeaderboardService.preview) {
        LeaderboardLoadingView()
    } content: {
        VStack {
            Text("No update time.")
        }
    }

}
