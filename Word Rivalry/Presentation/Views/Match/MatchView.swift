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
    @Environment(LocalUser.self) private var localUser
    @Environment(\.dismiss) private var dismiss
    @State private var matchViewModel = SoloMatchViewModel()
  
    
    init() {
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
                    localUser: localUser.user,
                    gameID: gameID,
                    socket: matchViewModel.battleSocket
                )
            case .ended(let gameResults):
                GameResultsView(gameResults: gameResults)
            }
            if matchViewModel.error != nil {
                BasicButton(text: "Exit", action: {
                    dismiss()
                })
            }
        }
        .onAppear {
            matchViewModel.currentState = .searching
        }
        .logLifecycle(viewName: "MatchView")
    }
}

#Preview {
    ViewPreview {
        MatchView()
    }
}
