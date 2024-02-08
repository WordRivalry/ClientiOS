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
    var cancellables = Set<AnyCancellable>()
  
    var ws: WebSocketService
    
    // Delagate data 
    var opponentUsername: String?
    var preGameCountdown: Int?
    
    init() {
        self.ws = WebSocketService()
        self.ws.matchmakingDelegate = self
    }
}

// MARK: MESSAGE SENT VIA WS
extension MatchmakingViewModel {
    func searchMatch() {
        ws.findMatch()
        // Update any relevant state or UI to indicate matchmaking is in progress
    }
    
    func cancelSearch() {
        ws.stopFindMatch()
        // Update state/UI as necessary to reflect that matchmaking was cancelled
    }
    
    func acknowledgeGameStart() {
        ws.ackStartGame()
        // Transition to the game view or state
    }
}

// MARK: MESSAGE RECEIVED VIA WS
extension MatchmakingViewModel: WebSocket_MatchmakingDelegate {
    func didReceiveOpponentUsername(opponentUsername: String) {
        DispatchQueue.main.async {
            self.opponentUsername = opponentUsername
            // Update any UI or state to reflect the opponent's username
        }
    }
    
    func didReceivePreGameCountDown(countdown: Int) {
        DispatchQueue.main.async {
            self.preGameCountdown = countdown
            // Update any UI or state to reflect the opponent's username
        }
    }
}
