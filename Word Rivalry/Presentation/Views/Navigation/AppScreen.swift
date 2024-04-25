//
//  AppScreen.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case home
    case battle
    case settings
    
    var id: AppScreen { self }
}

extension AppScreen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .home:
            Image(systemName: "heart.fill")
        case .battle:
            Image(systemName: "flag.filled.and.flag.crossed") // "flag.checkered")
        case .settings:
            Image(systemName: "gear")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .home:
            HomeNavigationStack()
        case .battle:
            BattleNavigationStack()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    ViewPreview {
        AppScreen.battle.label
    }
}
