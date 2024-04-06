//
//  MatchmakingModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-04.
//

import SwiftUI
import Combine
import os.log

struct GameInfo {
    let startTime: Int64
    let duration: Int
    var grid: [[LetterTile]]
}

@Observable class SearchModel {
    private let logger = Logger(subsystem: "com.WordRivalry", category: "SearchModel")
    var state: GameProcess = .searching
    var gameMode: GameMode = .RANK
    var modeType: ModeType = .NORMAL
    
    // Game model
    var gameModel: GameModel
    
    // User info
    var playerName: String
    let playerUUID: String
    
    // Delagate data
    var opponentUsername: String = ""
    var opponentElo: Int = 0
    var errorMessage: String?
    var preGameCountdown: Int = 0
    var presentGameResut: Bool = false
    
    init(modeType: ModeType, playerName: String, playerUUID: String) {
        
        self.playerName = playerName
        self.playerUUID = playerUUID
      
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
                self?.logger.debug("On game ended callback called.")
                self?.presentGameResut = true
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
            self.logger.debug("Match Found")
            self.opponentUsername = opponentUsername
            self.opponentElo = opponentElo
            self.gameModel.setOpponentName(playerName: opponentUsername)
            withAnimation(.easeInOut) {
                self.state = .inGame
            }
       
            // Start the connection
            BattleServerService.shared.connect(
                gameSessionUUID: gameSessionUUID,
                playerName: self.playerName,
                playerUUID: self.playerUUID
            )
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
