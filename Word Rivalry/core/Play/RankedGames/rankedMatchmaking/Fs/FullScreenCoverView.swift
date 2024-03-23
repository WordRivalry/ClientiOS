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
    case lobby
    case inGame // Holds the matchmaking type for the game
    case gameResult
}

struct FullScreenCoverView: View {
    var onGameEnded: (() -> Void)?
    @Bindable var searchModel: SearchModel
    
    init(gameMode: GameMode, modeType: ModeType) {
        self.searchModel = SearchModel(modeType: modeType)
    }
    
    var body: some View {
        ZStack {
            VStack {
                switch searchModel.state {
                case .searching:
                    SearchingView(viewModel: searchModel)
                case .lobby:
                    LobbyView(
                        opponentPlayerName: searchModel.opponentUsername,
                        myPlayerName: searchModel.myUsername,
                        opponentEloRating: searchModel.opponentElo,
                        myEloRating: 1149,
                        waitingForOpponent: .constant(true))
                case .inGame:
                    GameView(gameModel: searchModel.gameModel)
                case .gameResult:
                    GameResultsView(
                        gameResults: self.searchModel.gameModel.gameResults,
                        duration: self.searchModel.gameModel.gameDuration,
                        completeWordList: self.searchModel.gameModel.valid_words,
                        board: self.searchModel.gameModel.board
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CountdownOverlayView(countdown: $searchModel.preGameCountdown)
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    FullScreenCoverView(gameMode: GameMode.RANK, modeType: ModeType.NORMAL)
}
