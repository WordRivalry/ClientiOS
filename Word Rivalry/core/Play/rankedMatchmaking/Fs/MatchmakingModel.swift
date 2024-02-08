//
//  MatchmakingModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-04.
//

import SwiftUI
import Combine

struct GameInfo {
    let startTime: Int64
    let duration: Int
    var grid: [[LetterTile]]
}


@Observable class MatchmakingViewModel: ObservableObject {
    var process: MatchmakingProcess = .searching
    var matchmakingType: MatchmakingType = .normal
    
    // Game mode
    var gameModel: GameModel {
        switch self.matchmakingType {
            case .normal:
                return GameModel()
            case .blitz:
                return GameModel()
            case .mayhem:
                return GameModel()
        }
    }
    
    // User info
    var myUsername: String = "Lighthouse"
    
    // Delagate data
    var opponentUsername: String = ""
    var gameStartCountdown: Int = 0
    
    init(matchmakingType: MatchmakingType) {
        self.matchmakingType = matchmakingType
        WebSocketService.shared.setMatchmakingDelegate(self)
    }
}

// MARK: MESSAGE SENT VIA WS
extension MatchmakingViewModel {
    func searchMatch() {
        WebSocketService.shared.findMatch()
        // Update any relevant state or UI to indicate matchmaking is in progress
    }
    
    func cancelSearch() {
        WebSocketService.shared.stopFindMatch()
        // Update state/UI as necessary to reflect that matchmaking was cancelled
    }
    
    func acknowledgeGameStart() {
        WebSocketService.shared.ackStartGame()
        // Transition to the game view or state
    }
}

// MARK: MESSAGE RECEIVED VIA WS
extension MatchmakingViewModel: WebSocket_MatchmakingDelegate {
    func didReceiveOpponentUsername(opponentUsername: String) {
        DispatchQueue.main.async {
            self.opponentUsername = opponentUsername
            self.process = .lobby

        }
    }
    
    func didReceivePreGameCountDown(countdown: Int) {
        DispatchQueue.main.async {
            if countdown <= 1 { self.process = .inGame }
            self.gameStartCountdown = countdown
        }
    }
}
