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
            case .overall:
                OverallLeaderboardView()
            case .arena:
                VStack {
                    Picker("Mode", selection: $arenaMode) {
                        ForEach(ArenaMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    
                    ArenaLeaderboardView(arenaMode: $arenaMode)
                }
            case .achievements:
                AchievementsLeaderboardView()
            }
        }
        .padding(.top)
        .ignoresSafeArea()
    }
}

#Preview {
    ViewPreview {
        LeaderboardContentView(
            selectedLeaderboard: .constant(.arena),
            arenaMode: .constant(.solo)
        )
    }
}
