//
//  ContentView2.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI
import OSLog

@Observable class MainRouter {
    var showMatchScreen: Bool = false
}

struct ContentView: View {
    @Environment(LocalUser.self) private var localUser
    @State private var appScreen: AppScreen? = .play
    @State private var router = MainRouter()
    @State private var displaySettings = InGameDisplaySettings()
    
    init() {
        Logger.viewCycle.debug("~~~ ContentView init ~~~")
    }
    
    var body: some View {
        Group {
            if localUser.isUserSet == true {
                AppTabView(selection: $appScreen)
                    .environment(router)
                    .environment(displaySettings)
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
}

#Preview {
    ViewPreview {
        ContentView()
    }
}
