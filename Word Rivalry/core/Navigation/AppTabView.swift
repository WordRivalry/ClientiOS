//
//  AppTabView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

struct AppTabView: View {
    @Binding var selection: AppScreen?
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .tag(screen as AppScreen?)
                    .tabItem { screen.label }
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarColorScheme(.dark, for: .tabBar)
            }
        }
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
    }
}

#Preview {
    AppTabView(selection: .constant(.home))
        .environmentObject(ProfileService())
}

