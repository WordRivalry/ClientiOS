//
//  LeaderboardContentView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import SwiftUI

struct LeaderboardContentView: View {
    @Binding var selectedLeaderboard: LeaderboardType
    @Binding var arenaMode: ArenaMode
    
    var body: some View {
        ZStack {
            switch selectedLeaderboard {
            case .level:
                OverallLeaderboardView()
            case .allTimeStars:
                AllTimeStarsLeaderboardView()
            case .CurrentStars:
                CurrentStarsLeaderboardView()
            }
        }
        .padding(.top)
        .ignoresSafeArea()
    }
}

#Preview {
    ViewPreview {
        LeaderboardContentView(
            selectedLeaderboard: .constant(.allTimeStars),
            arenaMode: .constant(.solo)
        )
    }
}
