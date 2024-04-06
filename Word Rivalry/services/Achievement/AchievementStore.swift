//
//  AchievementStore.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import Foundation
import os.log

class AchievementStore {
    private var achievements: [String: Achievement] = [:]
    private let logger = Logger(subsystem: "com.WordRivalry", category: "AchievementStore")

    func addAchievement(_ achievement: Achievement) {
        achievements[achievement.name.rawValue] = achievement
    }
    
    func getAchievements() -> [Achievement] {
        return Array(achievements.values)
    }
    
    func getAchievement(name: String) -> Achievement? {
        return achievements[name]
    }
}



