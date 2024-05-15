//
//  LeaderboardNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import SwiftUI

enum ArenaMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case solo = "Solo"
    case team = "Team"
    
    var header: String {
        switch self {
        case .solo:
            return "Solo leaderboard"
        case .team:
            return "Team leaderboard"
        }
    }
    
    // Image name for each section
    var imageName: String {
        switch self {
        case .solo:
            return "Leaderboard/ArenaSolo"
        case .team:
            return "Leaderboard/ArenaTeam"
        }
    }
}

enum LeaderboardType: String, TabViewEnum {
    var id: String { rawValue }
    case level = "Level"
    case allTimeStars = "Total Stars"
    case CurrentStars = "Current Stars"
    
    // Custom header for each leaderboard section
    var header: String {
        switch self {
        case .level:
            return "Level Leaderboard"
        case .allTimeStars:
            return "Total Stars Competitions"
        case .CurrentStars:
            return "Current Starsff Leaderbord"
        }
    }
    
    // Image name for each section
    var imageName: String {
        switch self {
        case .level:
            return "Leaderboard/Overall"
        case .allTimeStars:
            return "Leaderboard/Arena"
        case .CurrentStars:
            return "Leaderboard/Achievement"
        }
    }
    
    // Menu options if needed
    var menuOptions: [String] {
        switch self {
        case .level:
            return ["Global Rank", "Local Rank", "Friends Rank"]
        case .allTimeStars:
            return ["1v1", "2v2", "3v3"]
        case .CurrentStars:
            return ["Unlocked", "Locked", "Progress"]
        }
    }
}

extension Color {
    static let lightGreen = Color(
        red: 151 / 255,
        green: 168 / 255,
        blue: 0 / 255
    )
    static let fontColor =  Color(
        red: 118 / 255.0,
        green: 100 / 255.0,
        blue: 74 / 255.0
    )
    static let lightTint = Color(
        red: 219 / 255.0,
        green: 220 / 255.0,
        blue: 153 / 255.0
    )
}

struct LeaderboardNavigationStack: View {
    @State private var selectedLeaderboard: LeaderboardType = .level
    @State private var arenaMode: ArenaMode = .solo
    
    var body: some View {
        VStack(spacing: 0) {
            LeaderboardHeaderView(
                selectedLeaderboard: $selectedLeaderboard,
                arenaMode: $arenaMode
            )
            
            HeaderTabView(selectedTab: $selectedLeaderboard)
            
            LeaderboardContentView(
                selectedLeaderboard: $selectedLeaderboard, arenaMode: $arenaMode
            )
            Spacer()
        }
        .defaultBackgroundIgnoreSafeBottomArea()
    }
}

#Preview {
    ViewPreview {
        LeaderboardNavigationStack()
    }
}
