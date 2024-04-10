//
//  SearchService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-07.
//

import Foundation
import SwiftUI
import os.log

class SearchService {
    
    static let shared = SearchService()
    
    private init() {}
    
    private let logger = Logger(subsystem: "com.WordRivalry", category: "SearchService")
    
    func searchMatch(modeType: ModeType, playerName: String, playerUUID: String, eloRating: Int) {
        do {
            // Connect to matchmaking server to start search
            try MatchmakingService.shared.connect(
                playerName: playerName,
                playerUUID: playerUUID
            )
            
            try MatchmakingService.shared.findMatch(
                gameMode: .RANK,
                modeType: modeType,
                eloRating: eloRating
            )
        } catch {
            self.logger.error("Error occurred: \(error.localizedDescription)")
        }
    }
    
    func cancelSearch() throws {
        try MatchmakingService.shared.stopFindMatch()
    }
}
