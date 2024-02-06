//
//  RankedMatchmakingService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-03.
//

import Foundation

class RankedMatchmakingService {
    func fetchStats(completion: @escaping ([String: (activePlayers: Int, inQueue: Int)], Error?) -> Void) {
        // Simulate a network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Base data
            let baseGameStats: [String: (activePlayers: Int, inQueue: Int)] = [
                "Normal Ranking": (activePlayers: 1243, inQueue: 58),
                "Blitz Ranking": (activePlayers: 987, inQueue: 34),
                "Mayhem Ranking": (activePlayers: 560, inQueue: 21)
            ]
            
            // Randomized data within ±10 tolerance
            let randomizedGameStats = baseGameStats.mapValues { stats in
                return (
                    activePlayers: stats.activePlayers + Int.random(in: -10...10),
                    inQueue: stats.inQueue + Int.random(in: -10...10)
                )
            }
            
            completion(randomizedGameStats, nil)
        }
    }

    
    func searchMatch(matchmakingType: MatchmakingType, completion: @escaping (Bool, Error?) -> Void) {
        // Simulate a network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Simulated search completion
            completion(true, nil)
        }
    }
}

