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
    @Environment(MyPublicProfile.self) private var profile
    @Environment(MainRouter.self) private var mainRouter
    
    
    init() {
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
                    SearchService.shared.cancelSearch()
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
           SearchService.shared.searchMatch(
               modeType: ModeType.NORMAL,
               playerName: profile.publicProfile.playerName,
               playerUUID: String(profile.publicProfile.recordID.recordName.prefix(10)),
               eloRating: profile.publicProfile.eloRating
           )
        }
        .edgesIgnoringSafeArea(.all)
        .handleNetworkChanges(onDisconnect: {
            Logger.matchmaking.debug("SearchView Dismissed")
            SearchService.shared.cancelSearch()
            mainRouter.showTabScreen = true
        })
        .logLifecycle(viewName: "MatchmakingView")
    }
}

#Preview {
    ViewPreview {
        MatchmakingView()
    }
}
