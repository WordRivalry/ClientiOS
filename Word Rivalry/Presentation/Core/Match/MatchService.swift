//
//  MatchOrchestrationService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-07.
//

import Foundation
import OSLog
import SwiftUI

enum MatchState: Equatable {
    case search
    case match(String, String) // GameID, OpponentName
}

@Observable class MatchService {
    var state: MatchState = .search
    
    var isValAlreadyGoing = false
    
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
    
    let db = PublicDatabase.shared.db
    
    var gameID: String = ""
    var ownProfile: PublicProfile
    var opponentProfile: PublicProfile = .nullProfile
    var gameModel: GameViewModel = GameViewModel()
    
    init(ownProfile: PublicProfile) {
        self.ownProfile = ownProfile
        self.state = .search

        self.ownProfile = ownProfile
        
        self.gameModel.onGameEnded = { soemBool in
            self.showGameResult = true
        }
        
        MatchmakingService.shared.setMatchmakingDelegate(self)
        
        Logger.match.info("*** MatchService init \(self.isValAlreadyGoing)***")
    }
}


extension MatchService: MatcMatchmakingDelegate {
    
    func didJoinedQueue() {}
    
    func didNotJoinedQueue() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
               // use error to dismiss the view
            }
        }
    }
    
    func didNotConnect() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
               
            }
        }
    }
    
    func didFoundMatch(gameSessionUUID: String, opponentUsername: String, opponentElo: Int) {
        Task {
            
            self.gameID = gameSessionUUID
            
            // Connect to battle server
            BattleServerService.shared.connect(
                gameSessionUUID: gameSessionUUID,
                playerName: self.ownProfile.playerName,
                playerUUID: self.ownProfile.recordID.recordName
            )
            
            do {
                self.opponentProfile = try await db.queryModel(by: .playerName, value: opponentUsername)
            } catch {
                self.opponentProfile = PublicProfile(
                    playerName: opponentUsername
                )
            }
            
            Logger.match.debug("opponentProfile fetched")
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
           
            await MainActor.run { // Switch to game view
                withAnimation(.easeInOut) {
                    self.state = .match(
                        gameSessionUUID,
                        opponentUsername
                    )
                }
            }
        }

        Logger.match.info("*** didFoundMatch delegate called ***")
    }
}
