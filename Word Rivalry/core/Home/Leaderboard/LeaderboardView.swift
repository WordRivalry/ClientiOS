//
//  LeaderboardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(AppDataService.self) private var appDataService: AppDataService
    @Environment(PublicProfile.self) var localProfile: PublicProfile
    @State private var showLocalProfileBottomRow = true
    
    var body: some View {
        VStack {
            header
            contentView
            Spacer()
            if showLocalProfileBottomRow {
                currentPlayerRow(players: appDataService.leaderboardService.players)
            }
            lastUpdatedView
         
            BasicDissmiss()
        }
        .onAppear {
            appDataService.leaderboardService.handleViewDidAppear()
        }
        .onDisappear {
            appDataService.leaderboardService.handleViewDidDisappear()
        }
    }
    
    @ViewBuilder
    private var header: some View {
        Text("Leaderboard")
            .font(.largeTitle)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if !appDataService.leaderboardService.isDataAvailable() && !NetworkChecker.shared.isConnected {
            noConnectionView
        } else if !appDataService.leaderboardService.isDataAvailable()  {
            LeaderboardLoadingView()
        } else {
            listView(players: appDataService.leaderboardService.players)
            
        }
    }
    
    @ViewBuilder
    private func listView(players: [PublicProfile]) -> some View {
        VisibilityTrackingScrollView(action: handleVisibilityChanged) {
            LazyVStack {
                ForEach(players.indices, id: \.self) { index in
                    LeaderboardRow(rank: index + 1, player: players[index])
                        .padding(.horizontal)
                        .trackVisibility(id: "\(players[index].playerName)")
                        .border(players[index].playerName == localProfile.playerName ? Color.accentColor : Color.clear, width: 4)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .coordinateSpace(.named("LeaderboardScroll"))
    }
    
    func handleVisibilityChanged(_ id: String, change: VisibilityChange, tracker: VisibilityTracker<String>) {
        switch change {
        case .shown:
            if id == localProfile.playerName {
                DispatchQueue.main.async {
                    self.showLocalProfileBottomRow = false
                }
            }

        case .hidden:
            if id == localProfile.playerName {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.showLocalProfileBottomRow = true
                    }
                 
                }
            }
        }
    }

    
    struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGPoint = .zero
        
        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        }
    }
    
    @ViewBuilder
    private func currentPlayerRow(players: [PublicProfile]) -> some View {
        
        if let rank = players.firstIndex(where: { $0.playerName == self.localProfile.playerName }) {
            LeaderboardRow(rank: rank + 1, player: self.localProfile)
                .padding(.horizontal)
                .border(Color.accentColor, width: 4)
                .cornerRadius(8)
        } else {
            Text("You are not ranked")
        }
    }
    
    @ViewBuilder
    private var noConnectionView: some View {
        Text("No internet connection and no cached data.")
    }
    
    @ViewBuilder
    private var loadingView: some View {
        Text("Loading...")
    }
    
    @ViewBuilder
    private var lastUpdatedView: some View {
        Group {
            if let lastUpdate = appDataService.leaderboardService.lastUpdateTime {
                Text("Last updated: \(lastUpdate.formatted())")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        LeaderboardView()
            .environment(AppDataService.preview)
            .environment(PublicProfile.preview)
    }
}


//
//BasicButton(text: "Send Achievment event") {
//    let buttonClickEvent = PlayerActionEvent(
//        type: .buttonClick,
//        data: [:],
//        timestamp: Date()
//    )
//
//    EventSystem.shared.publish(event: buttonClickEvent)
//}
