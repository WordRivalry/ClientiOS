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
    @Environment(\.modelContext) private var modelContext
    @Environment(MyPublicProfile.self) private var profile
    @Environment(MatchService.self) private var gameService
    @Environment(InGameDisplaySettings.self) private var inGameDisplay
   
    @State private var matchHistoric: MatchHistoric = .nullData
    @State private var showingQuitAlert = false

    init() {
        Logger.viewCycle.debug("~~~ GameView init ~~~")
    }
    
    var body: some View {
        @Bindable var gameModel = gameService.gameModel
        
        VStack {
            header
            Spacer()
            Upper
            LetterBoardView(viewModel: gameModel)
                .cornerRadius(10)
                .scaleEffect(0.9)
                .frame(maxWidth: .infinity, maxHeight: 400)
            Spacer()
            ForfeitButtonView(showingQuitAlert: showingQuitAlert)
            if inGameDisplay.showMessage {
                Text("\(gameModel.message)")
                    .padding(.horizontal)
            }
        }
        .onAppear {
            self.matchHistoric = MatchHistoric(
                gameID: gameService.gameID,
                ownScore: 0,
                thenOpponentName: gameService.opponentProfile.playerName,
                opponentRecordID: gameService.opponentProfile.recordID.recordName,
                opponentScore: 0
            )
        }
        .infinityFrame()
        .scoreChangeHandler(
            gameModel: gameService.gameModel,
            matchHistoric: matchHistoric,
            modelContext: modelContext
        )
        .gameLifecycleHandling(
            gameModel: gameService.gameModel,
            matchHistoric: matchHistoric,
            modelContext: modelContext,
            profile: profile
        )
        .logLifecycle(viewName: "GameView")
        .environment(gameService.gameModel)
    }
    
    @ViewBuilder
    private var header: some View {
        @Bindable var gameModel = gameService.gameModel
        
        HStack {
            PlayerView(
                profile: profile.publicProfile,
                showScore: true,
                score: $gameModel.currentScore
            )
            .padding(.horizontal)
            Spacer()
            ClockView(timeleft: $gameModel.timeLeft)
            Spacer()
            PlayerView(
                profile: gameService.opponentProfile,
                showScore: inGameDisplay.showOpponentScore,
                score: $gameModel.opponentScore
            )
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var Upper: some View {
        @Bindable var gameModel = gameService.gameModel
        
        HStack {
            Text("Path: \(gameModel.currentPathScore)")
                .padding(.horizontal)
            Spacer()
            LastFiveWordsView(alreadyDoneWords: gameModel.alreadyDoneWords)
        }
        .opacity(inGameDisplay.showScorePath ? 1 : 0)
    }
}

extension View {
    func scoreChangeHandler(gameModel: GameViewModel, matchHistoric: MatchHistoric, modelContext:  ModelContext) -> some View {
        self
            .onChange(of: gameModel.currentScore) {
                Logger.gameView.debug("MyScore: (newScore)")
                matchHistoric.ownScore = gameModel.currentScore
                saveContext(context: modelContext)
            }
            .onChange(of: gameModel.opponentScore) {
                Logger.gameView.debug("OpponentScore: (newScore)")
                matchHistoric.opponentScore = gameModel.opponentScore
                saveContext(context: modelContext)
            }
    }
    
    private func saveContext(context:  ModelContext) {
        do {
            try context.save()
        } catch {
            Logger.gameView.error("Save model context failure on score change: \(error.localizedDescription)")
        }
    }
}

extension View {
    func gameLifecycleHandling(gameModel: GameViewModel, matchHistoric: MatchHistoric, modelContext: ModelContext, profile: MyPublicProfile) -> some View {
        self
            .onAppear {
                modelContext.insert(matchHistoric)
                gameModel.startGame()
                Logger.gameView.debug("Game started - 10 Elo points deducted")
                Task {
                    try await profile.subtractEloPoint(amountToSubtract: 10)
                }
            }
            .onDisappear {
                do {
                    try modelContext.save()
                } catch {
                    Logger.gameView.error("Save model context failure on disappear: \(error.localizedDescription)")
                }
                handleGameResults(gameModel: gameModel, profile: profile)
            }
    }
    
    private func handleGameResults(gameModel: GameViewModel, profile: MyPublicProfile) {
        Task {
            if gameModel.currentScore > gameModel.opponentScore {
                Logger.gameView.debug("Game won - 20 Elo points rewarded")
                try await profile.addEloPoint(amountToAdd: 20)
            } else if gameModel.currentScore < gameModel.opponentScore {
                Logger.gameView.debug("Game Lost - No reward.")
            } else {
                Logger.gameView.debug("Game Draw - Give back elo points.")
                try await profile.addEloPoint(amountToAdd: 10)
            }
        }
    }
}


#Preview {
    let gameModel = GameViewModel()
    gameModel.board = Board(
        rows: 4,
        cols: 4,
        initialValue: LetterTile(
            letter: "A",
            value: 1,
            letterMultiplier: 1,
            wordMultiplier: 1)
    )
    
    gameModel.opponentName = "Player 1"
    gameModel.opponentScore = 20
    gameModel.timeLeft = "10"
    gameModel.message = "Message field"
    
    return ViewPreview {
        GameView()
    }
}
