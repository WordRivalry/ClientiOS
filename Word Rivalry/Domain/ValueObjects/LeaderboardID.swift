//
//  LeaderboardID.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-02.
//

import Foundation


enum LeaderboardSetID: String, Codable {
    case normal = "NormalLeaderboardSet"
}

enum LeaderboardID: String, Codable, RandomCaseProvidable {
    case allTimeStars = "allTimeStars"
    case currentStars = "CurrentStars"
    case experience = "Experience"
}
