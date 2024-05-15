//
//  MatchViewModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-25.
//

import Foundation
import SwiftUI
import OSLog
import GameKit

typealias Adversary = User
typealias GameID = String

enum MatchState {
    case searching
    case matchFound(GameID, Adversary)
    case ended(GameResults)
}

enum GameError: Error {
    case notOngoing
    case invalidMove
    case invalidWord
    case gameFinished
}


@Observable final class SoloMatchViewModel {
    private(set) var matchmakingSocket: MatchmakingSocketService
    private(set) var battleSocket: BattleSocketService
    
    var currentState: MatchState = .searching
    var stars: Int
    var error: Error?

    init(
        stars: Int,
        matchmakingSocket: MatchmakingSocketService = MatchmakingSocketService(),
        battleSocket: BattleSocketService = BattleSocketService()
    ) {
        self.stars = stars
        self.matchmakingSocket = matchmakingSocket
        self.battleSocket = battleSocket
        self.matchmakingSocket.setMatchFoundDelegate(self)
        self.battleSocket.setGameEndedDelegate(self)
    }
}

extension SoloMatchViewModel: MatchmakingSocketService_MatchFound_Delegate {
    func didFoundMatch(gameSessionUUID: String, opponentUsername: String, opponentElo: Int) {
        Task {
            do {
                // Work
                let adversary = try await FetchSomeUser.execute(with: opponentUsername)
                await LocalUser.shared.decreaseStars(by: stars)
                
                //UI
                await MainActor.run {
                    currentState = .matchFound(gameSessionUUID, adversary)
                }
            } catch {
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        self.error = MatchmakingSessionError.adversaryNotFound
                    }
                }
                return
            }
            
            Logger.match.debug("opponentProfile fetched")
        }
    }
}

extension SoloMatchViewModel: BattleSocketService_GameEnded_Delegate {
    func didReceiveGameResult(winner: String, playerResults: [PlayerResult]) {
        
        let interactor: UserAndLeaderboardCoordinator = .init()
        
        Task {
            
            // Work
            let gameResults = GameResults(winner: winner, playerResults: playerResults)
            
            if GKLocalPlayer.local.displayName == winner {
                try await interactor.updateSoloGame(won: true, stars: stars * 2)
            } else {
                try await interactor.updateSoloGame(won: false, stars: 0)
            }
            
            // UI
            await MainActor.run {
                currentState = .ended(gameResults)
            }
        }
    }
}
