//
//  Achievement.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-29.
//

import Foundation
import SwiftData

// MARK: - ACHIEVEMENT DEFINITION
enum AchievementCategory: String, CaseIterable {
    case beginner
    case mastery
}

struct Progression {
    var current: Int
    var target: Int
    var isComplete: Bool {
        return current >= target
    }
}

enum AchievementType {
    case oneTime
    case repeatableWithTier(target: Int, currentTier: Int = 0, maxTier: Int)
    case rapidAction(requiredActions: Int, timeFrame: TimeInterval)
}

protocol AchievementCriteria {
    func isFulfilled(by event: AnyEvent) -> Bool
}

struct AchievementUnlockedEvent: AnyEvent {
    var type: AchievementEventType
    var data: [String: Any]
    var timestamp: Date
    var anyType: AnyEventType { return type }
}

enum RewardContent {
    case title(Title)
    case banner(Banner)
    case profileImage(ProfileImage)
    case points(Int)
}

enum Achievements {
    case firstLogin
    case wordMastery
    case ButtonClicker
}

@Model
class AchievementData {
    var name: String = ""
    var desc: String = ""
    var category: AchievementCategory
    var reward: [RewardContent]?
    var progression: Progression?
    
    init(
        name: String,
        desc: String, 
        category: AchievementCategory,
        reward: [RewardContent]? = nil,
        progression: Progression? = nil
    ) {
        self.name = name
        self.desc = desc
        self.category = category
        self.reward = reward
        self.progression = progression
    }
}

class AchievementProgression {
    var achievement: AchievementData
    var type: AchievementType
    var criteria: AchievementCriteria
    var isUnlocked: Bool = false
    private var actionTimestamps: [Date] = []
    
    init(
        achievement: AchievementData,
        type: AchievementType,
        criteria: AchievementCriteria
    ) {
        self.achievement = achievement
        self.type = type
        self.criteria = criteria
    }
    
    func evaluate(event: AnyEvent) {
        switch type {
        case .oneTime:
            if !isUnlocked && criteria.isFulfilled(by: event) {
                unlock()
            }
        case .repeatableWithTier(let target, _, _):
            if criteria.isFulfilled(by: event) {
                achievement.progression?.current += 1
                if achievement.progression?.isComplete == true {
                    unlock()
                    if case .repeatableWithTier(_, let currentTier, let maxTier) = type, currentTier < maxTier {
                        // Reset progression for the next tier
                        achievement.progression?.current = 0
                        type = .repeatableWithTier(target: target, currentTier: currentTier + 1, maxTier: maxTier)
                    }
                }
            }
        case .rapidAction(let requiredActions, let timeFrame):
            // Add the timestamp of the current event
            if criteria.isFulfilled(by: event) {
                actionTimestamps.append(event.timestamp)
                
                // Remove timestamps that are outside of the allowable time frame
                let thresholdDate = Date().addingTimeInterval(-timeFrame)
                actionTimestamps = actionTimestamps.filter { $0 > thresholdDate }
                
                // Check if the number of actions within the time frame meets the requirement
                if actionTimestamps.count >= requiredActions {
                    unlock()
                }
            }
        }
    }
    
    func unlock() {
        self.isUnlocked = true
        print("\(achievement.name) Achievement Unlocked!")
        
        // Prepare and publish an event
        let event = AchievementUnlockedEvent(
            type: .achievementUnlocked,
            data: ["achievementID": achievement.id, "name": achievement.name],
            timestamp: Date()
        )
        
        EventSystem.shared.publish(event: event)
        
        // Handle reward
        if let reward = achievement.reward {
            print("Reward: \(reward)")
        }
    }
}


// Define criteria for an example achievement
struct WordMasterCriteria: AchievementCriteria {
    func isFulfilled(by event: AnyEvent) -> Bool {
        guard let eventType = event.anyType as? PlayerActionEventType else { return false }
        return eventType == .word && (event.data["wordLength"] as? Int ?? 0) >= 8
    }
}


// Initialize an achievement
let wordMasterAchievement = AchievementData(
    name: "Button Clicker",
    desc: "Click on a button",
    category: .mastery,
    reward: [.banner(.defaultProfileBanner), .title(.wordSmith), .profileImage(.PI_0)],
    progression: Progression(current: 0, target: 2)
)

