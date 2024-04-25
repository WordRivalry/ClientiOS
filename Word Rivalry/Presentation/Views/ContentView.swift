//
//  ContentView2.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI
import OSLog

@Observable class MainRouter {
    var showTabScreen: Bool = true
}

struct ContentView: View {
    @Environment(UserViewModel.self) private var userViewModel
    @State private var appScreen: AppScreen? = .home
    @State private var router = MainRouter()
    @State private var displaySettings = InGameDisplaySettings()
    
    init() {
        Logger.viewCycle.debug("~~~ ContentView init ~~~")
    }
    
    var body: some View {
        Group {
            if userViewModel.user != nil {
                mainScreen
            } else {
                Text("Awaiting user data...")
            }
        }
        .onAppear(perform: userViewModel.fetchUser)
        .overlay {
            GlobalOverlayView()
        }
        .logLifecycle(viewName: "ContentView")
    }
    
    @ViewBuilder
    private var mainScreen: some View {
        Group {
            switch router.showTabScreen {
            case true:
                AppTabView(selection: $appScreen)
                
            case false:
                MatchView(profile: userViewModel.user)
            }
        }
        .environment(LeaderboardViewModel())
        .environment(router)
        .environment(displaySettings)
    }
}

#Preview {
    ViewPreview {
        ContentView()
    }
}
