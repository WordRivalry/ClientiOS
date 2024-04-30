//
//  GamesView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI
import OSLog

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
        VStack(spacing: 20) {
            Divider()
            
            GameCardView(cardName: ModeType.SOLO) {
                withAnimation {
                    mainRouter.showTabScreen = false
                }
            }
            
            GameCardView(cardName: ModeType.DUO) {
                withAnimation {
                    mainRouter.showTabScreen = false
                }
            }
        }
    }
}

#Preview {
    ViewPreview {
        BattleMainView()
    }
}
