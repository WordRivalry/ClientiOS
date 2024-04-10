//
//  MatchOrchestrationService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-07.
//

import Foundation
import os.log
import SwiftUI

enum MatchOrchestrationState: Equatable {
    case inGame
    case gameResult
}

@Observable class MatchService {
    
    private let logger = Logger(subsystem: "com.WordRivalry", category: "MatchOrchestrationService")
    
    var state: MatchOrchestrationState
    var showMatchView: Bool = false
    var showGameResult: Bool = false
    var joinedQueueSuccess: Bool = false
    var errorMessage: String? {
        didSet { // On change
            // Check if it's non-nil to control the alert presentation
            showErrorAlert = errorMessage != nil
        }
    }
    var showErrorAlert = false
    
    // Players
    var localProfile: PublicProfile
    var opponentProfile: PublicProfile?
    
    var gameModel: GameModel
    
    init(
        localProfile: PublicProfile,
        modeType: ModeType,
        gameSessionUUID: String,
        opponentUsername: String
    ) {
        self.logger.info("*** MatchOrchestrationService STARTED ***")
        self.localProfile = localProfile
        self.state = .inGame
        
        // Instanciate the right game model
        if modeType == .NORMAL {
            self.gameModel = GameModel()
        } else {
            self.gameModel = GameModel()
        }
        
        self.gameModel.onGameEnded = { [weak self] isWinner in
            self?.state = .gameResult
            self?.showGameResult = true
            if isWinner {
              //  eloService.attributePoint()
            }
        }
        
        self.logger.debug("GameModel created")
        
        self.opponentProfile = PublicProfile( // When not found
            userRecordID: "ND",
            playerName: opponentUsername
        )
  
        // Fetch opponent profile
        Task {
            do {
                self.opponentProfile = try await PublicDatabase.shared.fetchPublicProfile(forPlayerName: opponentUsername)
            } catch {
                self.opponentProfile = PublicProfile( // When not found
                    userRecordID: "ND",
                    playerName: opponentUsername
                )
            }
            
            self.logger.debug("opponentProfile fetched")
            try? await Task.sleep(nanoseconds: 300_000_000)
            // Update UI elements
            await MainActor.run {
               
                withAnimation(.easeInOut) {
                    self.state = .inGame
                }
            }
        }
    }
}




//extension MatchOrchestrationService: BattleServerDelegate_GameStartCountdown {
//    func didReceivePreGameCountDown(countdown: Int) {
//
//        self.preGameCountdown = countdown
//
//        if (countdown <= 1 ) {
//            withAnimation(.easeInOut) {
//                self.state = .inGame
//            }
//        }
//    }
//}

