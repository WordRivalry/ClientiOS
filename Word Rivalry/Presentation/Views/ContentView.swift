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
    @Environment(LocalUser.self) private var localUser
    @State private var appScreen: AppScreen? = .home
    @State private var router = MainRouter()
    @State private var displaySettings = InGameDisplaySettings()
    
    init() {
        Logger.viewCycle.debug("~~~ ContentView init ~~~")
    }
    
    var body: some View {
        Group {
            if localUser.isUserSet == true {
                mainScreen
            } else {
                Text("Awaiting user data...")
            }
        }
        .onAppear { Task {
            try await localUser.fetchUser()
        }}
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
                MatchView()
            }
        }
       
        .environment(router)
        .environment(displaySettings)
    }
}

#Preview {
    ViewPreview {
        ContentView()
    }
}
