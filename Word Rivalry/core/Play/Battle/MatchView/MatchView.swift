//
//  MatchOrchestrationView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-07.
//

import SwiftUI
import os.log

struct MatchView: View {
    private let logger = Logger(subsystem: "com.WordRivalry", category: "MatchOrchestrationView")
    
    let service: MatchService
    var showGameResult: Bool {
        service.state == .gameResult
    }
    
    init(profile: PublicProfile,
         modeType: ModeType,
         gameSessionUUID: String,
         opponentUsername: String
    ) {
        
        self.logger.debug("*** MatchOrchestrationView INITIATED ***")
        
        self.service = MatchService(
            localProfile: profile,
            modeType: modeType,
            gameSessionUUID: gameSessionUUID,
            opponentUsername: opponentUsername
        )
    }
    
    var body: some View {
        @Bindable var service = service
        
        VStack {
            switch service.state {
            case .inGame, .gameResult:
                GameView(
                    gameModel: service.gameModel,
                    opponentProfile: service.opponentProfile!
                )
                .allowsHitTesting(showGameResult ? false : true)
                .blurredOverlayWithAnimation(isPresented: $service.showGameResult) {
                    gameResultsOverlay
                }
            }
        }
        .environment(service)
    }
    
    @ViewBuilder
    private var gameResultsOverlay: some View {
        GameResultsView(
            gameResults: service.gameModel.gameResults,
            duration: service.gameModel.gameDuration,
            completeWordList: service.gameModel.valid_words,
            board: service.gameModel.board
        )
    }
}

#Preview {
    ViewPreview {
        MatchView(
            profile: PublicProfile.preview,
            modeType: .NORMAL,
            gameSessionUUID: "23e4234",
            opponentUsername: "Bluehouse"
        )
    }
}
