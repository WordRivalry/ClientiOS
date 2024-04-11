//
//  DataView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI

struct JITDataView<Service: JITData, LoadingView: View, Content: View>: View {
    let dataService: JITData
    let loadingView: () -> LoadingView
    let content: () -> Content

    var body: some View {
        VStack {
            contentView
                .onChange(of: NetworkChecker.shared.isConnected) { oldValue, newValue in
                    if oldValue == false || newValue == true {
                        Task {
                            await dataService.fetchData()
                        }
                    }
                }
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
            VStack {
                Spacer()
                InternetStatusMessageView(message: "No available data")
                Spacer()
                BasicDissmiss()
            }
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
    JITDataView(dataService: LeaderboardService.preview) {
        LeaderboardLoadingView()
    } content: {
        VStack {
            Text("No update time.")
        }
    }

}
