//
//  SearchView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI
import OSLog

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the search view events from the app
    static let matchmaking = Logger(subsystem: subsystem, category: "Matchmaking")
}

struct MatchmakingView: View {
    @Environment(LocalUser.self) private var localUser
    @Environment(MainRouter.self) private var mainRouter
    @State private var matchmakingViewModel: SoloMatchmakingViewModel
    
    init(socket: MatchmakingSocketService) {
        self.matchmakingViewModel = SoloMatchmakingViewModel(
            matchmakingSocket: socket
        )
        Logger.viewCycle.debug("~~~ SearchingView init ~~~")
    }
    
    var body: some View {
        ZStack {
            AnimatedCirclesView()
            VStack {
                Text("Matchmaking")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                Spacer()
                Text("Searching")
                    .foregroundColor(.primary)
                    .font(.title2)
                    .padding()
                    .shadow(radius: 10)
                    .blinkingEffect()
                Spacer()
                Button {
                    
                    // try matchmakingViewModel.leaveQueue() // Switching to tab should dc
                    mainRouter.showTabScreen = true
                    Logger.matchmaking.debug("SearchView Dismissed")
                } label: {
                    Text("Cancel")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            
            if localUser.isUserSet == false {
                Logger.matchmaking.fault("No user set for matchmaking")
                mainRouter.showTabScreen = true
            }
            
            Task {
                try await matchmakingViewModel.joinQueue()
            }
          
        }
        .edgesIgnoringSafeArea(.all)
        .handleNetworkChanges(onDisconnect: {
            Logger.matchmaking.debug("SearchView Dismissed")
            //matchmakingViewModel.leaveQueue()
            mainRouter.showTabScreen = true
        })
        .logLifecycle(viewName: "MatchmakingView")
    }
}

#Preview {
    ViewPreview {
        MatchmakingView(socket: MatchmakingSocketService())
    }
}
