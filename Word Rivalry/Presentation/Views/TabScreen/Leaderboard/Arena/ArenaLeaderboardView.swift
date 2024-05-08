//
//  ArenaLeaderboard.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import SwiftUI
import GameKit

struct ArenaLeaderboardView: View {
    @Binding var arenaMode: ArenaMode
    @Environment(LeaderboardViewModel.self) private var leaderboard
    @Environment(LocalUser.self) var localUser
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
            if let topPlayers = leaderboard.allTimeStars {
                listView(players: topPlayers.top50.map( { entry in (entry.user, entry.displayName) } ))
                Spacer()
                if showMyProfileBottomRow {
                 //   currentPlayerRow(players: topPlayers.localEntry)
                }
                lastUpdatedView
            }
        }
    }
    
    @ViewBuilder
    private func listView(players: [(User, String)]) -> some View {
        
        
        VisibilityTrackingScrollView(action: handleVisibilityChanged) {
            LazyVStack {
                ForEach(players.indices, id: \.self) { index in
                    LeaderboardRow(
                        rank: index + 1,
                        player: players[index].0,
                        username: players[index].1,
                        content: Text(
                            "Win \(players[index].0.soloWin) / \(players[index].0.soloMatch)")
                            .font(.caption)
                    )
                        .padding(.horizontal)
                        .trackVisibility(id: "\(players[index].1)")
                        .border(players[index].1 == GKLocalPlayer.local.displayName ? Color.accentColor : Color.clear, width: 4)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .coordinateSpace(.named("LeaderboardScroll"))
    }
    
    
//    private var achievementsView: some View {
//        HStack {
//            Spacer()
//            VStack {
//                TitleView(title: player.title)
//                    .frame(width: 140)
//                    .font(.caption)
//                    .padding(.vertical, 5)
//    
//             
//            }
//        }
//    }
    
    func handleVisibilityChanged(_ id: String, change: VisibilityChange, tracker: VisibilityTracker<String>) {
        switch change {
        case .shown:
            if id == GKLocalPlayer.local.displayName {
                DispatchQueue.main.async {
                    self.showMyProfileBottomRow = false
                }
            }
            
        case .hidden:
            if id == GKLocalPlayer.local.displayName {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.showMyProfileBottomRow = true
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
    
//    @ViewBuilder
//    private func currentPlayerRow(players: [User]) -> some View {
//        if let rank = players.firstIndex(where: { $0.username == GKLocalPlayer.local.displayName }) {
//            LeaderboardRow(
//                rank: rank + 1,
//                player: localUser.user
//            )
//            .padding(.horizontal)
//            .border(Color.accentColor, width: 4)
//            .cornerRadius(8)
//        }
//    }
    
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
        ArenaLeaderboardView(arenaMode: .constant(.solo))
    }
}
