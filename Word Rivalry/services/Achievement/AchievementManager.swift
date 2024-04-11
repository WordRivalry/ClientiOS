//
//  AchievementManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import Foundation
import os.log

class AchievementsManager {
    static let shared = AchievementsManager()
    private var achievementStores: [AchievementCategory: AchievementStore] = [:]
    private let logger = Logger(subsystem: "com.WordRivalry", category: "AchievementsManager")
 
    init() {
        // Initialize the stores for each category
        AchievementCategory.allCases.forEach { category in
            achievementStores[category] = AchievementStore()
        }
        self.logger.debug("Achievement Manager init...")
        // Load achievements into their respective store
        loadAchievements()
    }
    
    // The profile has an array of progression
    // Check if a new achievement is missing progression within profile
    func checkIfMissingProgression() {
        AchievementName.allCases.forEach { achievementName in
            Task {
                let progression = await SwiftDataSource.shared.fetchAchievementProgression().first(where: { progression in
                    progression.name == achievementName.rawValue
                })
                if (progression == nil ) { // Add it to the achievements
                    await SwiftDataSource.shared.appendAchievementProgression(self.newProgression(for: achievementName))
                }
            }
        }
    }
    
    private func loadAchievements() {
        AchievementName.allCases.forEach { achievementName in
            let achievement = self.forKey(achievementName)
            if let store = achievementStores[achievement.category] {
                store.addAchievement(achievement)
                self.logger.debug("Achievement \(achievementName.rawValue) loaded")
            }
        }
    }
    
    func getAllAchievements() -> [AchievementCategory: [Achievement]] {
        var allAchievements: [AchievementCategory: [Achievement]] = [:]
        
        for (category, store) in achievementStores {
            allAchievements[category] = store.getAchievements()
        }
        self.logger.debug("Achievements fetched")
        return allAchievements
    }
    
//    func getUnlockedAchievements() -> [AchievementCategory: [Achievement]] {
//        var unlockedAchievements: [AchievementCategory: [Achievement]] = [:]
//        
//        for (category, store) in achievementStores {
//            unlockedAchievements[category] = store.getUnlockedAchievements()
//        }
//        
//        return unlockedAchievements
//    }
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
                name: key,
                desc: "A spcecific button was click",
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
                name: key,
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
                name: key,
                desc: "A word of 9 letters",
                type: .oneTime,
                category: .mastery,
                criteria: WordSmithCriteria.init()
            )
        }
    }
    
    func newProgression(for achievementName: AchievementName) -> AchievementProgression {
        switch achievementName {
        case .ButtonClicker:
            AchievementProgression(name: achievementName.rawValue, current: 0, target: 2)
        case .wordConqueror:
            AchievementProgression(name: achievementName.rawValue, current: 0, target: 1)
        case .wordSmith:
            AchievementProgression(name: achievementName.rawValue, current: 0, target: 1)
        }
    }
}


extension AchievementsManager: EventSubscriber {
    
    func handleEvent(_ event: AnyEvent) {
        self.logger.debug("Achievements event handling")
        achievementStores.values.forEach { store in
            store.getAchievements().forEach { achievement in
                self.evaluate(event: event, achievement: achievement)
            }
        }
    }
    
    @MainActor func isUnlocked(achievementName: AchievementName) -> Bool {
        self.logger.debug("isUnlocked for \(achievementName.rawValue)")
        guard let progression: AchievementProgression = SwiftDataSource.shared
            .fetchAchievementProgression()
            .first(where: { progression in
                progression.name == achievementName.rawValue
            })
        else { return false }
        return progression.isComplete
    }
    
    func evaluate(event: AnyEvent, achievement: Achievement) -> Void {
        Task {
            self.logger.debug("Evaluate for \(achievement.name.rawValue)")
            let progression: AchievementProgression? = await SwiftDataSource.shared.fetchAchievementProgression()
                .first(where: { progression in
                    progression.name == achievement.name.rawValue
                })
            
            guard let progression = progression else { self.logger.error("No progression found for \(achievement.name.rawValue)"); return }
            self.logger.debug("progression found for \(achievement.name.rawValue)")
            if (progression.isComplete) {  print("Progression complete for \(achievement.name)");  return }
            
            switch achievement.type {
            case .oneTime:
                if achievement.criteria.isFulfilled(by: event) {
                    Task { @MainActor in
                        progression.progress(by: 1)
                        self.logger.debug("Progression updated for \(achievement.name.rawValue)");
                        if (progression.isComplete) {
                            self.logger.debug("Progression complete for \(achievement.name.rawValue)");
                            self.unlock(achievement: achievement)
                        }
                    }
                }
            case .rapidAction(let requiredActions, let timeFrame):
                // Add the timestamp of the current event
                if achievement.criteria.isFulfilled(by: event) {
                    achievement.actionTimestamps.append(event.timestamp)
                    
                    // Remove timestamps that are outside of the allowable time frame
                    let thresholdDate = Date().addingTimeInterval(-timeFrame)
                    achievement.actionTimestamps = achievement.actionTimestamps.filter { $0 > thresholdDate }
                    
                    // Check if the number of actions within the time frame meets the requirement
                    if achievement.actionTimestamps.count >= requiredActions {
                        self.unlock(achievement: achievement)
                    }
                }
            }
        }
    }
    
    func unlock(achievement: Achievement) {
        self.logger.debug("\(achievement.name.rawValue) Achievement Unlocked!")
        
        // Prepare and publish an event
        let event = AchievementUnlockedEvent(
            type: .achievementUnlocked,
            name: achievement.name.rawValue,
            data: [:],
            timestamp: Date()
        )
        
        EventSystem.shared.publish(event: event)
        
        NotificationManager.shared.triggerNotification(for: achievement.name)
    }
}

