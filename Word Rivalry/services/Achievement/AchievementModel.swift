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

enum AchievementType {
    case oneTime
  //  case repeatableWithTier(target: Int, currentTier: Int = 0, maxTier: Int)
    case rapidAction(requiredActions: Int, timeFrame: TimeInterval)
}

protocol AchievementCriteria {
    func isFulfilled(by event: AnyEvent) -> Bool
}

enum AchievementName: String, CaseIterable {
    case ButtonClicker = "Button Clicker"
    case firstLogin = "First Login"
    case wordConqueror = "Word Conqueror"
    case wordSmith = "Word Smith"
}

class Achievement {
    var name: String
    var desc: String
    var type: AchievementType
    var category: AchievementCategory
    var criteria: AchievementCriteria
    private var actionTimestamps: [Date] = []
    var progression: AchievementProgression?
    
    init(
        name: String,
        desc: String,
        type: AchievementType,
        category: AchievementCategory,
        criteria: AchievementCriteria
    ) {
        self.name = name
        self.desc = desc
        self.type = type
        self.category = category
        self.criteria = criteria
    }
    
    func setProgression(progression: AchievementProgression) {
        self.progression = progression
    }
    
    func evaluate(event: AnyEvent) {
        guard let progression = self.progression else { print("No progression is set"); return }
        if (progression.isComplete) { return }
        switch type {
        case .oneTime:
            if !progression.isComplete && criteria.isFulfilled(by: event) {
                self.unlock()
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
                    self.unlock()
                }
            }
        }
    }
    
    func unlock() {
        print("\(name) Achievement Unlocked!")

        // Prepare and publish an event
        let event = AchievementUnlockedEvent(
            type: .achievementUnlocked,
            data: ["name": name],
            timestamp: Date()
        )

        EventSystem.shared.publish(event: event)
    }
}

// MARK: - MODELS

struct AchievementUnlockedEvent: AnyEvent {
    var type: AchievementEventType
    var data: [String: Any]
    var timestamp: Date
    var anyType: AnyEventType { return type }
}

// Only the achievement progression is persisted via swiftData as we dont need anything else
@Model
class AchievementProgression {
    var name: String = ""
    var current: Int = 0
    var target: Int = 0
    
    @Relationship(inverse: \Profile.achievementsProgression)
    var profile: Profile?
    
    @Transient
    var isComplete: Bool {
        return current >= target
    }
    
    init(
        name: String,
        current: Int,
        target: Int
    ) {
        self.name = name
        self.current = current
        self.target = target
    }
    
    func progress(by: Int) {
        current += 1
    }
    
    static var preview: AchievementProgression {
        AchievementProgression(
            name: AchievementName.ButtonClicker.rawValue,
            current: 0,
            target: 1
        )
    }
}
