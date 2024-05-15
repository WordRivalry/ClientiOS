//
//  ArenaLeaderboard.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import SwiftUI
import GameKit

struct CurrentStarsLeaderboardView: View {
    var leaderboard: LeaderboardViewModel = .init(leaderboardID: .currentStars)
  
    var body: some View {
        LeaderboardView(
            viewModel: leaderboard,
            content: content
        )
        .logLifecycle(viewName: "CurrentStarsLeaderboardView")
    }
    
    @ViewBuilder
    func content(entry: LeaderboardEntry) -> some View {
        Text("Stars: \(entry.formattedScore)")
    }
}

#Preview {
    ViewPreview {
        CurrentStarsLeaderboardView()
    }
}
