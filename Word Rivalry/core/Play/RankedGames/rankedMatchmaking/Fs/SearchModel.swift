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
    var state: GameProcess = .searching
    var gameMode: GameMode = .RANK
    var modeType: ModeType = .NORMAL
    
    // Game model
    var gameModel: GameModel
    
    // User info
    var myUsername: String
    
    // Delagate data
    var opponentUsername: String = ""
    var opponentElo: Int = 0
    var errorMessage: String?
    var preGameCountdown: Int = 0
    
    init(modeType: ModeType) {
        
        self.myUsername = ProfileService.shared.getUsername()
      
        // Instanciate game model
        switch modeType {
        case .NORMAL:
            self.gameModel = GameModel()
        case .BLITZ:
            self.gameModel = GameModel()
        }
        
        self.gameModel.onGameEnded = { [weak self] in
            DispatchQueue.main.async {
                self?.state = .gameResult
            }
        }
        
        self.modeType = modeType
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
            self.gameModel.setOpponentName(playerName: opponentUsername)
            withAnimation(.easeInOut) {
                self.state = .lobby
            }
       
            // Start the connection
            BattleServerService.shared.connect(gameSessionUUID: gameSessionUUID)
        }
    }
}

extension SearchModel: BattleServerDelegate_GameStartCountdown {
    func didReceivePreGameCountDown(countdown: Int) {
        
        self.preGameCountdown = countdown
        
        if (countdown <= 1 ) {
            withAnimation(.easeInOut) {
                self.state = .inGame
            }
        }
    }
}
