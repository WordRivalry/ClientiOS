//
//  LeaderboardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(LeaderboardViewModel.self) private var leaderboard
    @Environment(UserViewModel.self) var userVM
    @State private var showMyProfileBottomRow = true
    
    var body: some View {
        JITDataView(for: leaderboard) {
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
            if let topPlayers = leaderboard.topPlayers {
                listView(players: topPlayers)
                Spacer()
                if showMyProfileBottomRow {
                    currentPlayerRow(players: topPlayers)
                }
                lastUpdatedView
            }
            BasicDismiss()
        }
    }
    
    @ViewBuilder
    private var header: some View {
        Text("Leaderboard")
            .font(.largeTitle)
    }
    
    @ViewBuilder
    private func listView(players: [User]) -> some View {
        if let user = userVM.user {
            
            VisibilityTrackingScrollView(action: handleVisibilityChanged) {
                LazyVStack {
                    ForEach(players.indices, id: \.self) { index in
                        LeaderboardRow(rank: index + 1, player: players[index])
                            .padding(.horizontal)
                            .trackVisibility(id: "\(players[index].playerName)")
                            .border(players[index].playerName == user.playerName ? Color.accentColor : Color.clear, width: 4)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .coordinateSpace(.named("LeaderboardScroll"))
        }
  
    }
    
    func handleVisibilityChanged(_ id: String, change: VisibilityChange, tracker: VisibilityTracker<String>) {
        
        if let user = userVM.user {
            switch change {
            case .shown:
                if id == user.playerName {
                    DispatchQueue.main.async {
                        self.showMyProfileBottomRow = false
                    }
                }

            case .hidden:
                if id == user.playerName {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            self.showMyProfileBottomRow = true
                        }
                     
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
    private func currentPlayerRow(players: [User]) -> some View {
        
        if let user = userVM.user {
            if let rank = players.firstIndex(where: { $0.playerName == user.playerName }) {
                LeaderboardRow(
                    rank: rank + 1,
                    player: user
                )
                    .padding(.horizontal)
                    .border(Color.accentColor, width: 4)
                    .cornerRadius(8)
            } else {
                Text("You are not ranked")
            }
        } else {
            Text("Information not available at this moment.")
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
