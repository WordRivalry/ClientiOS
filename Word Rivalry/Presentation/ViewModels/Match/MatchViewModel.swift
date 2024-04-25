//
//  MatchViewModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-25.
//

import Foundation
import SwiftUI
import OSLog

enum MatchVMState {
    case searching
    case matchFound(String, User)
    case ended(GameResults)
}

@Observable final class MatchViewModel {
    private(set) var matchmakingSocket: MatchmakingSocketService = MatchmakingSocketService()
    private(set) var battleSocket: BattleSocketService = BattleSocketService()
    
    var currentState: MatchVMState = .searching
    var error: Error?
    init() {
        matchmakingSocket.setMatchFoundDelegate(self)
        battleSocket.setGameEndedDelegate(self)
    }
}

extension MatchViewModel: MatchmakingSocketService_MatchFound_Delegate {
    func didFoundMatch(gameSessionUUID: String, opponentUsername: String, opponentElo: Int) {
        let fetchUser = FetchSomeUser()
        
        Task {
            do {
                let adversary = try await fetchUser.execute(request: opponentUsername)
                currentState = .matchFound(gameSessionUUID, adversary)
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

extension MatchViewModel: BattleSocketService_GameEnded_Delegate {
    func didReceiveGameResult(winner: String, playerResults: [PlayerResult]) {
        Task {
            
            // Work
            let gameResults = GameResults(winner: winner, playerResults: playerResults)
            
            // UI
            await MainActor.run {
                currentState = .ended(gameResults)
            }
        }
    }
}
