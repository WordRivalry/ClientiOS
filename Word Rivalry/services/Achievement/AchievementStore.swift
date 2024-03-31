//
//  AchievementStore.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import Foundation

class AchievementStore {
    private var achievements: [String: Achievement] = [:]

    func addAchievement(_ achievement: Achievement) {
        achievements[achievement.name] = achievement
    }
    
    func getAchievements() -> [Achievement] {
        return Array(achievements.values)
    }
    
    func evaluateAchievements(for event: AnyEvent) {
        achievements.values.forEach { achievement in
            achievement.evaluate(event: event)
        }
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return achievements.values.filter( {
            guard let progression = $0.progression else { return false }
            return progression.isComplete
        })
    }
    
    func getAchievement(name: String) -> Achievement? {
        return achievements[name]
    }
}



