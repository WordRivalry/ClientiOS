//
//  MatchOrchestrationView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-07.
//

import SwiftUI
import os.log

struct MatchView: View {
    @State private var matchService: MatchService
    
    init(profile: PublicProfile) {
        self.matchService = MatchService(ownProfile: profile)
        Logger.viewCycle.debug("~~~ MatchView init ~~~")
    }
    
    var body: some View {
        @Bindable var service = matchService
        
        VStack {
            ZStack {
                GameView()
                    .allowsHitTesting(service.showGameResult ? false : true)
                    .blurredOverlayWithAnimation(isPresented: $service.showGameResult) {
                        gameResultsOverlay
                    }
                
                if service.state == .search {
                    MatchmakingView()
                        .background(
                            RoundedRectangle(cornerRadius: 0)
                                .fill(.ultraThinMaterial)
                        )
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            service.state = .search
        }
        .background(.ultraThinMaterial)
        .logLifecycle(viewName: "MatchView")
        .environment(matchService)
    }
    
    @ViewBuilder
    private var gameResultsOverlay: some View {
        GameResultsView(
            gameResults: matchService.gameModel.gameResults,
            duration: matchService.gameModel.gameDuration,
            completeWordList: matchService.gameModel.valid_words,
            board: matchService.gameModel.board
        )
    }
}

#Preview {
    ViewPreview {
        MatchView(
            profile: PublicProfile.preview
        )
    }
}
