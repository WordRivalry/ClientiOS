//
//  MatchmakingUCError.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

enum MatchmakingUCError: Error {
    case statusUnavailable
    case notConnected
    case disconnected
    case matchmakingUnavailable
}
