//
//  NormalAchivement.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import SwiftUI
import GameKit

struct AllTimeStarsLeaderboardView: View {
    var leaderboard: LeaderboardViewModel = .init(leaderboardID: .allTimeStars)
  
    var body: some View {
        LeaderboardView(
            viewModel: leaderboard,
            content: content
        )
        .logLifecycle(viewName: "OverallLeaderboardView")
    }
    
    @ViewBuilder
    func content(entry: LeaderboardEntry) -> some View {
        Text("Stars: \(entry.formattedScore)")
    }
}


#Preview {
    ViewPreview {
        AllTimeStarsLeaderboardView()
    }
}
