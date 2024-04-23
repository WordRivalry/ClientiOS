//
//  GameSession.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation

enum GameSessionError: Error {
    case gameStateNotYetInitialized
}

@Observable final class GameSession {
    
    private var local: User
    private let adversary: User
    private let battleSocket: BattleSocketService
    
    // For updates on receiving data
    var gameState: GameState?
    
    init(
        gameID: String,
        local: User,
        adversary: User,
        gameState: GameState,
        battleSocket: BattleSocketService = BattleSocketService()
    ) {
        self.local = local
        self.adversary = adversary
        self.gameState = gameState
        self.battleSocket = battleSocket
        self.battleSocket.setGameDelegate(self)
        
        // Connection to server
        self.battleSocket.connect(
            gameID: gameID,
            playerID: local.recordName,
            playerName: local.playerName
        )
    }
    
    deinit {
        self.battleSocket.disconnect()
    }
    
    // MARK: Reduce User Elo Rating
    private let reduceUserEloRating = ReduceUserEloRating()
    
    func reduceUserEloRating(by amount: Int) async throws -> User {
        self.local = try await self.reduceUserEloRating.execute(request: amount)
        return self.local
    }
    
    // MARK: Increase User Elo Rating
    private let increaseUserEloRating = IncreaseUserEloRating()
    
    func increaseUserEloRating(by amount: Int) async throws -> User {
        self.local = try await self.increaseUserEloRating.execute(request: amount)
        return self.local
    }
    
    // MARK: Forfeit
    private let forfeit = Forfeit()
    
    func forfeit() async throws -> Void {
        let request = ForfeitRequest(battleSocket: self.battleSocket)
        try await self.forfeit.execute(request: request)
    }
    
    // MARK: SubmitWord
    private let submitWord = SubmitWord()
    
    func submitWord(wordPath: [(Int, Int)]) async throws -> Void {
        
        let wordScore = getGameState().tryWord(path: wordPath)
        
        guard wordScore != 0 else {
            return // Skip
        }
        
        // Convert to correct format
        let wordPath: WordPath = wordPath.map { element in
            return [element.0, element.1]
        }
        
        // Send to adversary
        let request = SubmitWordRequest(
            wordPath: wordPath,
            battleSocket: self.battleSocket
        )
        try await self.submitWord.execute(request: request)
    }
}

// MARK: WebSocket_GameDelegate
extension GameSession: WebSocket_GameDelegate {
    
    func didReceiveGameInformation(
        startTime: Date,
        endTime: Date,
        grid: [[LetterTile]],
        valid_words: [String],
        stats: GridStats
    ) {
        Task {
            // Work
            let duration = endTime.timeIntervalSince(startTime).rounded(.toNearestOrAwayFromZero)
            let board = Board(grid: grid)
            let gameState = GameState(
                startTime: startTime,
                endTime: endTime,
                board: board,
                valid_words: valid_words,
                stats: stats
            )
            
            // Assignation
            await MainActor.run {
                self.gameState = gameState
            }
        }
    }
    
    func didReceiveOpponentScore(_ score: Int) {
        Task { @MainActor in
            
            // Assignation
            getGameState().opponentScore = score
        }
    }
    
    func didReceiveGameResult(winner: String, playerResults: [PlayerResult]) {
        Task {
            // Work
            let gameResults = GameResults(winner: winner, playerResults: playerResults)
            
            // Assignation
            await MainActor.run {
                getGameState().gameResults = gameResults
            }
        }
    }
    
    private func getGameState() -> GameState {
        guard let gameState = gameState else {
            fatalError(GameSessionError.gameStateNotYetInitialized.localizedDescription)
        }
        return gameState
    }
}
