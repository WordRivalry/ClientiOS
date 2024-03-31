//
//  AchievementManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import Foundation

class AchievementsManager {
    static let shared = AchievementsManager()
    private var achievementStores: [AchievementCategory: AchievementStore] = [:]
    
    init() {
        // Initialize the stores for each category
        AchievementCategory.allCases.forEach { category in
            achievementStores[category] = AchievementStore()
        }
        // Load achievements into their respective store
        loadAchievements()
    }
    
    private func loadAchievements() {
        AchievementName.allCases.forEach { achievementName in
            let achievement = self.forKey(achievementName)
            if let store = achievementStores[achievement.category] {
                store.addAchievement(achievement)
            }
        }
    }
    
    func updateAchievementsProgression(with progressionData: [AchievementProgression]) {
        progressionData.forEach { progressionInstance in
            let achievementName = progressionInstance.name
            // Find the achievement by name across all stores and update its progression
            for store in achievementStores.values {
                if let achievement = store.getAchievement(name: achievementName) {
                    achievement.setProgression(progression: progressionInstance)
                }
            }
        }
    }
    
    func getAllAchievements() -> [AchievementCategory: [Achievement]] {
        var allAchievements: [AchievementCategory: [Achievement]] = [:]
        
        for (category, store) in achievementStores {
            allAchievements[category] = store.getAchievements()
        }
        
        return allAchievements
    }
    
    func getUnlockedAchievements() -> [AchievementCategory: [Achievement]] {
        var unlockedAchievements: [AchievementCategory: [Achievement]] = [:]
        
        for (category, store) in achievementStores {
            unlockedAchievements[category] = store.getUnlockedAchievements()
        }
        
        return unlockedAchievements
    }
}

extension AchievementsManager {
    func forKey(_ key: AchievementName) -> Achievement {
        switch key {
        case .ButtonClicker:
            struct ButtonClickCriteria: AchievementCriteria {
                func isFulfilled(by event: AnyEvent) -> Bool {
                    guard let eventType = event.anyType as? PlayerActionEventType else { return false }
                    return eventType == PlayerActionEventType.buttonClick
                }
            }
            
            return Achievement(
                name: key.rawValue,
                desc: "A spcecific button was click",
                type: .oneTime,
                category: .beginner,
                criteria: ButtonClickCriteria.init()
            )
            
        case .firstLogin:
            struct ButtonClickCriteria: AchievementCriteria {
                func isFulfilled(by event: AnyEvent) -> Bool {
                    guard let eventType = event.anyType as? PlayerActionEventType else { return false }
                    return eventType == PlayerActionEventType.login
                }
            }
            
            return Achievement(
                name: key.rawValue,
                desc: "A login was done",
                type: .oneTime,
                category: .beginner,
                criteria: ButtonClickCriteria.init()
            )
        case .wordConqueror:
            struct WordConquerorCriteria: AchievementCriteria {
                func isFulfilled(by event: AnyEvent) -> Bool {
                    guard let eventType = event.anyType as? PlayerActionEventType else { return false }
                    return eventType == .word(.word8Letters) && (event.data["wordLength"] as? Int ?? 0) >= 8
                }
            }
            
            return Achievement(
                name: key.rawValue,
                desc: "A word of 8 letters",
                type: .oneTime,
                category: .mastery,
                criteria: WordConquerorCriteria.init()
            )
        case .wordSmith:
            struct WordSmithCriteria: AchievementCriteria {
                func isFulfilled(by event: AnyEvent) -> Bool {
                    guard let eventType = event.anyType as? PlayerActionEventType else { return false }
                    return eventType == .word(.word8Letters) && (event.data["wordLength"] as? Int ?? 0) >= 9
                }
            }
            
            return Achievement(
                name: key.rawValue,
                desc: "A word of 9 letters",
                type: .oneTime,
                category: .mastery,
                criteria: WordSmithCriteria.init()
            )
        }
    }
}


extension AchievementsManager: EventSubscriber {
    func handleEvent(_ event: AnyEvent) {
        achievementStores.values.forEach { store in
            store.evaluateAchievements(for: event)
        }
    }
}

