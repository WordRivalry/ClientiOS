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

@Observable class SearchModel {
    var process: GameProcess = .searching
    var gameMode: GameMode = .RANK
    var modeType: ModeType = .NORMAL
    
    // Game mode
    var gameModel: GameModel
    
    // User info
    var myUsername: String = "Lighthouse"
    
    // Delagate data
    var opponentUsername: String = ""
    var opponentElo: Int = 0
    var errorMessage: String?
    var gameStartCountdown: Int = 0
    
    init(modeType: ModeType) {
        print("FS COVER model")
        self.modeType = modeType
        
        switch modeType {
            case .NORMAL:
                self.gameModel = GameModel()
            case .BLITZ:
                self.gameModel = GameModel()
            
            self.gameModel.onGameEnded = { [weak self] in
                DispatchQueue.main.async {
                    self?.process = .gameEnded
                }
            }
        }
        
        MatchmakingService.shared.setMatchmakingDelegate_onMatchFound(self)
        BattleServerService.shared.setMatchmakingDelegate(self)
    }
}

// MARK: MESSAGE SENT VIA WS
extension SearchModel {
    func cancelSearch() throws {
        try MatchmakingService.shared.stopFindMatch()
    }
}

// MARK: MESSAGE RECEIVED VIA WS
extension SearchModel: MatchmakingDelegate_onMatchFound {
    
    func didFoundMatch(gameSessionUUID: String, opponentUsername: String, opponentElo: Int) {
        DispatchQueue.main.async {
            print("Match Found")
            self.opponentUsername = opponentUsername
            self.opponentElo = opponentElo
            withAnimation(.easeInOut) {
                self.process = .lobby
            }
            
            // Start the connection
            BattleServerService.shared.connect(gameSessionUUID: gameSessionUUID)
            BattleServerService.shared.joinGameSession()
        }
    }
}

extension SearchModel: BattleServerDelegate_GameStartCountdown {
    func didReceivePreGameCountDown(countdown: Int) {
        
        self.gameStartCountdown = countdown
        
        if (countdown <= 1 ) {
            withAnimation(.easeInOut) {
                self.process = .inGame
            }
        }
    }
}
