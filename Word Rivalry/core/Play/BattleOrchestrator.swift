//
//  RouterService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-07.
//

import Foundation
import os.log
import SwiftUI

@Observable class BattleOrchestrator {
    private let logger = Logger(subsystem: "BattleOrchestrator", category: "info")
    
    var currentPage: Page = .searching
    var profile: PublicProfile
    var eloService: EloRatingService
    var modeType: ModeType
    
    init(profile: PublicProfile, modeType: ModeType) {
        self.logger.info("*** BattleOrchestrator init ***")
        self.profile = profile
        self.modeType = modeType
        self.eloService = EloRatingService(for: profile)
        MatchmakingService.shared.setMatchmakingDelegate(self)
    }
    
    func setProfile(profile: PublicProfile) {
        self.profile = profile
        self.eloService = EloRatingService(for: profile)
    }
    
    deinit {
        self.logger.info("*** BattleOrchestrator deinit ***")
    }
}

enum Page {
    case searching
    case match(ModeType, String, String) // Type, GameUUID, oppName
}

extension BattleOrchestrator: MatcMatchmakingDelegate {
    
    func didJoinedQueue() {  }
    
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
        self.eloService.setPendingAmount(amount: 10)
        self.eloService.deductPoint()

        // Connect to battle server
        BattleServerService.shared.connect(
            gameSessionUUID: gameSessionUUID,
            playerName: self.profile.playerName,
            playerUUID: self.profile.userRecordID
        )
        
        Task { @MainActor in
            self.currentPage = .match(
                self.modeType,
                gameSessionUUID,
                opponentUsername
            )
        }

        self.logger.info("*** didFoundMatch delegate called ***")
    }
}
