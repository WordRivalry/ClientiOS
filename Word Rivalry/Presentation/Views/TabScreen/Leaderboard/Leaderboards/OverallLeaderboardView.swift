//
//  LeaderboardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct OverallLeaderboardView: View {
    var leaderboard: LeaderboardViewModel = .init(leaderboardID: .experience)
  
    var body: some View {
        LeaderboardView(
            viewModel: leaderboard,
            content: content
        )
        .logLifecycle(viewName: "OverallLeaderboardView")
    }
    
    @ViewBuilder
    func content(entry: LeaderboardEntry) -> some View {
        Text("Level \(entry.formattedScore)")
    }
}

#Preview {
    ViewPreview {
        OverallLeaderboardView()
    }
}
