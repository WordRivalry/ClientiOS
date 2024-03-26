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

struct FullScreenCoverView: View {
    var onGameEnded: (() -> Void)?
    @Bindable var searchModel: SearchModel
    
    init(gameMode: GameMode, modeType: ModeType) {
           self.searchModel = SearchModel(modeType: modeType)
        searchModel.state = .gameResult
    }
     
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

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

#Preview {
    FullScreenCoverView(gameMode: GameMode.RANK, modeType: ModeType.NORMAL)
}
