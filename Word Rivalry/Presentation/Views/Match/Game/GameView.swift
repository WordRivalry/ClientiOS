//
//  GameView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI
import OSLog
import SwiftData

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the app events from the app
    static let gameView = Logger(subsystem: subsystem, category: "GameView")
}


struct GameView: View {
    @Environment(InGameDisplaySettings.self) private var inGameDisplay
   
    @State private var showingQuitAlert = false
    @State private var gameViewModel: SoloGameViewModel
    @State private var adversary: User
    @State private var localUser: User
    @State private var gameID: String

    init(
        adversary: User,
        localUser: User,
        gameID: String,
        socket: BattleSocketService
    ) {
        self.adversary = adversary
        self.localUser = localUser
        self.gameID = gameID
        self.gameViewModel = SoloGameViewModel(
            gameID: gameID,
            localUser: localUser,
            adversary: adversary,
            battleSocket: socket
        )
        Logger.viewCycle.debug("~~~ GameView init ~~~")
    }
    
    var body: some View {
        @Bindable var interactor = gameViewModel.boardInteractor!
        VStack {
            header
            Spacer()
            Upper
            LetterBoardView(viewModel: interactor)
                .cornerRadius(10)
                .scaleEffect(0.9)
                .frame(maxWidth: .infinity, maxHeight: 400)
            Spacer()
            ForfeitButtonView(showingQuitAlert: showingQuitAlert)
        }
        .onAppear {
           
        }
        .infinityFrame()
        .logLifecycle(viewName: "GameView")
    }

    
    private var header: some View {
        HStack {
            
            if let game = gameViewModel.game {
                PlayerView(
                    profile: localUser,
                    showScore: true,
                    score: game.localScore
                )
                .padding(.horizontal)
            }
            
           
            Spacer()
            ClockView(timeleft: "\(gameViewModel.timeRemaining)")
            Spacer()
            PlayerView( 
                profile: adversary,
                showScore: inGameDisplay.showOpponentScore,
                score: gameViewModel.adversaryScore
            )
            .padding(.horizontal)
        }
    }
 
    @ViewBuilder
    private var Upper: some View {
        HStack {
            if let game = gameViewModel.game {
                LastFiveWordsView(alreadyDoneWords: Array(game.wordsFound))
            }
        }
        .opacity(inGameDisplay.showScorePath ? 1 : 0)
    }
}

#Preview {
     ViewPreview {
         GameView(adversary: .previewOther, localUser: .preview, gameID: "", socket: BattleSocketService())
    }
}
