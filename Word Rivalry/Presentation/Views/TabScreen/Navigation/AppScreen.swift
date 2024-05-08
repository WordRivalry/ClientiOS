//
//  AppScreen.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case career
    case leaderboard
    case play
    case achievement
    case collection
    
    var id: AppScreen { self }
}

extension AppScreen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .career:
            Label("Personal", systemImage: "person.crop.circle.fill")
        case .leaderboard:
            Label("Leaderboard", systemImage: "square.3.layers.3d.down.left")
        case .play:
            Label("Battle", systemImage: "square.grid.3x3")
        case .achievement:
            Label("Achievement", systemImage: "scroll")
        case .collection:
            Label("Settings", systemImage: "gearshape")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .career:
            CareerNavigationStack()
        case .leaderboard:
            LeaderboardNavigationStack()
        case .play:
            BattleNavigationStack()
        case .achievement:
            AchievementNavigationStack()
        case .collection:
            SettingsView()
        }
    }
}

#Preview {
    ViewPreview {
        AppScreen.play.label
    }
}
