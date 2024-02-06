//
//  RankedMarchmakingModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-03.
//

import Foundation

@Observable class RankedMatchmakingModel {
    var gameStats: [String: (activePlayers: Int?, inQueue: Int?)] = [
            MatchmakingType.normal.rawValue: (nil, nil),
            MatchmakingType.blitz.rawValue: (nil, nil),
            MatchmakingType.mayhem.rawValue: (nil, nil)
        ]
    var isLoading: Bool = false
    var isSearching: [MatchmakingType: Bool] = [:]
    var errorMessage: String?
    var matchFound: ((MatchmakingType) -> Void)?
    var nextTournament: Date = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
    private var service = RankedMatchmakingService()
    
    init() {
        fetchStats()
    }
    
    func fetchStats() {
        isLoading = true
        service.fetchStats { [weak self] gameStats, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.gameStats = gameStats
                }
            }
        }
    }
    
    func searchMatch(matchmakingType: MatchmakingType) {
        isSearching[matchmakingType] = true
        service.searchMatch(matchmakingType: matchmakingType) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isSearching[matchmakingType] = false
                if success {
                    self?.matchFound?(matchmakingType)
                } else if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
