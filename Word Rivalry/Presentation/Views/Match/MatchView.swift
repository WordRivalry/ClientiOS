//
//  MatchOrchestrationView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-07.
//

import SwiftUI
import os.log

struct MatchView: View {
    @Environment(MainRouter.self) private var mainRouter
    @State private var matchViewModel = MatchViewModel()
  
    
    @State private var local: User
    
    init(local: User) {
        self.local = local
        Logger.viewCycle.debug("~~~ MatchView init ~~~")
    }
    
    var body: some View {
        VStack {
            switch matchViewModel.currentState {
            case .searching:
                MatchmakingView(socket: matchViewModel.matchmakingSocket)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(.ultraThinMaterial)
                    )
                    .ignoresSafeArea()
            case .matchFound(let gameID, let adversary):
                GameView(
                    adversary: adversary,
                    local: local,
                    gameID: gameID,
                    socket: matchViewModel.battleSocket
                )
            case .ended(let gameResults):
                GameResultsView(gameResults: gameResults)
            }
            if matchViewModel.error != nil {
                BasicButton(text: "Exit", action: {
                    mainRouter.showTabScreen = true
                })
            }
        }
        .onAppear {
            matchViewModel.currentState = .searching
        }
        .background(.ultraThinMaterial)
        .logLifecycle(viewName: "MatchView")
    }
}

#Preview {
    ViewPreview {
        MatchView(
            local: User.preview
        )
    }
}
