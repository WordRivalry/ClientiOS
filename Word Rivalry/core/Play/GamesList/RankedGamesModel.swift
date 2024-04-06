//
//  RankedMarchmakingModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-03.
//

import Foundation
import SwiftUI

@Observable class RankedGamesModel: ObservableObject {
    var showingCover = false
    var errorMessage: String? {
        didSet { // On change
            // Check if it's non-nil to control the alert presentation
            showErrorAlert = errorMessage != nil
        }
    }
    var showErrorAlert = false
    
    var nextTournament: Date = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
    var activeGameMode: GameMode = .RANK
    var activeModeType: ModeType = .NORMAL
    
    init() {
        MatchmakingService.shared.setMatchmakingDelegate(self)
    }
    
    func searchMatch(modeType: ModeType, playerName: String, playerUUID: String) {
        do {
            self.activeModeType = modeType
            try MatchmakingService.shared.connect(playerName: playerName, playerUUID: playerUUID)
            self.showingCover = true
            try MatchmakingService.shared.findMatch(
                gameMode: self.activeGameMode,
                modeType: self.activeModeType
            )
        } catch {
            print("Error occurred: \(error)")
        }
    }
}

extension RankedGamesModel: MatcMatchmakingDelegate_onSearch {
    
    func didJoinedQueue() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                print("Opening FS Cover")
                self.showingCover = true
            }
        }
    }
    
    func didNotJoinedQueue() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.errorMessage = "Failed to join a queue, retry later."
                print("Closing FS Cover")
                self.showingCover = false
            }
        }
    }
    
    func didNotConnect() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.errorMessage = "Connection to Matchmaking Server failed"
                print("Closing FS Cover")
                self.showingCover = false
            }
        }
    }
    
    func didNotSendMessage() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.errorMessage = "Sending WebSocket Message Failed"
                print("Closing FS Cover")
                self.showingCover = false
            }
        }
    }
}
