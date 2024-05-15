//
//  GamesView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI
import OSLog


enum GKGameCenterViewControllerState2 : Int {
   case `default`
   case leaderboards
   case achievements
   case challenges
   case localPlayerProfile
   case dashboard
}

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the app events from the app
    static let battle = Logger(subsystem: subsystem, category: "battle")
}

// MARK: BattleMainView

struct BattleMainView: View {
    @Environment(MainRouter.self) private var mainRouter
    
    init() {
        Logger.viewCycle.debug("~~~ PlayView init ~~~")
    }
  
    var body: some View {
        @Bindable var router = mainRouter
        
        VStack(spacing: 20) {
            Divider()
            
            GameCardView(cardName: ModeType.SOLO) {
                withAnimation {
                    mainRouter.showMatchScreen = true
                }
            }
            
            GameCardView(cardName: ModeType.DUO) {
                withAnimation {
                    mainRouter.showMatchScreen = true
                }
            }
            
            BasicButton(text: "Dashbaoard") {
                GameCenter.shared.showGKGameCenter(state: .localPlayerProfile
                )
            }
            
            BasicButton(text: "Leaderboards") {
                GameCenter.shared.showGKGameCenter(state: .leaderboards
                )
            }
            
            
            BasicButton(text: "Achievements") {
                GameCenter.shared.showGKGameCenter(state: .achievements
                )
            }
        }
        .fullScreenCover(isPresented: $router.showMatchScreen, content: {
            MatchView()
                .presentationBackground(.bar)
                .fadeIn()
        })
    }
}

#Preview {
    ViewPreview {
        BattleMainView()
    }
}
