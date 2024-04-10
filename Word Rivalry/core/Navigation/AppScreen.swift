//
//  AppScreen.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case home
    case play
    case settings
    
    var id: AppScreen { self }
}

extension AppScreen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .home:
            Label("Home", systemImage: "house.fill")
                .foregroundStyle(Color.accentColor)
        case .play:
            Label("Play", systemImage: "flag.checkered")
                .foregroundStyle(Color.accentColor)
        case .settings:
            Label("Settings", systemImage: "gear")
                .foregroundStyle(Color.accentColor)
        }
    }
    
    @ViewBuilder
    var destination: some View {
        
        
        switch self {
        case .home:
            HomeNavigationStack()
        case .play:
            PlayNavigationStack()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        AppScreen.home.label
    }
}
