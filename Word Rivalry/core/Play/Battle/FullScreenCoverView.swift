//
//  SearchingFullScreenCoverView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-04.
//


import SwiftUI
import Combine

enum GameProcess {
    case searching
    case inGame // Holds the matchmaking type for the game
    case gameResult
}

import SwiftUI
import SwiftData

struct FullScreenCoverView: View {
    var onGameEnded: (() -> Void)?
    @Environment(Profile.self) private var profile: Profile
    @Bindable var searchModel: SearchModel
     
    var showGameResult: Bool {
        searchModel.state == .gameResult
    }
    
    var body: some View {
        GameViewContainer()
            .blurredOverlayWithAnimation(isPresented: $searchModel.presentGameResut) {
                 GameResultsOverlay()
             }
    }
    
    @ViewBuilder
    private func GameViewContainer() -> some View {
        VStack {
            switch searchModel.state {
            case .searching:
                SearchingView(viewModel: searchModel)
            case .inGame, .gameResult: // Keep the game view present but blurred when showing results
                GameView(gameModel: searchModel.gameModel)
                    .allowsHitTesting(
                        searchModel.state == .gameResult ? false : true
                    )
            }
        }
    }
    
    @ViewBuilder
    private func GameResultsOverlay() -> some View {
        GameResultsView(
            gameResults: searchModel.gameModel.gameResults,
            duration: searchModel.gameModel.gameDuration,
            completeWordList: searchModel.gameModel.valid_words,
            board: searchModel.gameModel.board
        )
    }
}

#Preview {
    FullScreenCoverView(searchModel: SearchModel(modeType: .NORMAL, playerName: "Lighthouse", playerUUID: "LighthouseUUID"))
        .environment(Profile.preview)
}
