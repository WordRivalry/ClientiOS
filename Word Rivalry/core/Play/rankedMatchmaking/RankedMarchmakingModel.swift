//
//  RankedMarchmakingModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-03.
//

import Foundation
import SwiftUI

@Observable class RankedMatchmakingModel: ObservableObject {
    var gameStats: [String: (activePlayers: Int?, inQueue: Int?)] = [
        ModeType.NORMAL.rawValue: (nil, nil),
        ModeType.BLITZ.rawValue: (nil, nil),
        ]
    var isLoading: Bool = false
    var showingCover = false
    var errorMessage: String?
    var nextTournament: Date = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
    var activeGameMode: GameMode = .RANK
    var activeModeType: ModeType = .NORMAL
//    private var statService = RankedMatchmakingStatsService()
    
    init() {
        MatchmakingService.shared.setMatchmakingDelegate(self)
    }
    
    func searchMatch(modeType: ModeType) {
        do {
            self.activeModeType = modeType
            MatchmakingService.shared.connect()
            self.showingCover = true
            try MatchmakingService.shared.findMatch(
                gameMode: self.activeGameMode,
                modeType: self.activeModeType
            )
        } catch {
            print("Error occurred: \(error)")
        }
    }
    
//    func fetchStats() {
//        isLoading = true
//        statService.fetchStats { [weak self] gameStats, error in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                if let error = error {
//                    self?.errorMessage = error.localizedDescription
//                } else {
//                    self?.gameStats = gameStats
//                }
//            }
//        }
//    }
}

extension RankedMatchmakingModel: MatcMatchmakingDelegate_onSearch {
    
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
