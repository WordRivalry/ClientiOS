//
//  LeaderboardRepositoryProtocol.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation

protocol LeaderboardRepositoryProtocol {
    func fetchTopPlayers(limit: Int) async throws -> [User]
}
