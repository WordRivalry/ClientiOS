//
//  LeaderboardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(LeaderboardService.self) private var leaderboard: LeaderboardService
    @Environment(PublicProfile.self) var localProfile: PublicProfile
    @State private var showLocalProfileBottomRow = true
    
    var body: some View {
        JITDataView(dataService: leaderboard) {
            LeaderboardLoadingView()
        } content: {
            content
        }
        .logLifecycle(viewName: "LeaderboardView")
    }
    
    @ViewBuilder
    private var content: some View {
        VStack {
            header
            listView(players: leaderboard.players)
            Spacer()
            if showLocalProfileBottomRow {
                currentPlayerRow(players: leaderboard.players)
            }
            lastUpdatedView
         
            BasicDissmiss()
        }
    }
    
    @ViewBuilder
    private var header: some View {
        Text("Leaderboard")
            .font(.largeTitle)
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
    private var lastUpdatedView: some View {
        Group {
            if let lastUpdate = leaderboard.lastUpdateTime {
                Text("Last updated: \(lastUpdate.formatted())")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ViewPreview {
        LeaderboardView()
    }
}
