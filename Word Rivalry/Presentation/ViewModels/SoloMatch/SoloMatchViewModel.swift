//
//  MatchViewModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-25.
//

import Foundation
import SwiftUI
import OSLog

typealias Adversary = User
typealias GameID = String

enum MatchState {
    case searching
    case matchFound(GameID, Adversary)
    case ended(GameResults)
}

@Observable final class SoloMatchViewModel {
    private(set) var matchmakingSocket: MatchmakingSocketService
    private(set) var battleSocket: BattleSocketService
    
    var currentState: MatchState = .searching
    var error: Error?

    init(
        matchmakingSocket: MatchmakingSocketService = MatchmakingSocketService(),
        battleSocket: BattleSocketService = BattleSocketService()
    ) {
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
                try await LocalUser.shared.decreaseCurrentPoints(by: 20)
                
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
        Task {
            
            // Work
            let gameResults = GameResults(winner: winner, playerResults: playerResults)
            
            if true {
                try await LocalUser.shared.increaseCurrentPoints(by: 20)
            }
            
            // UI
            await MainActor.run {
                currentState = .ended(gameResults)
            }
        }
    }
}
