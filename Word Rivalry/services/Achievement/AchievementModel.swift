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
    case wordConqueror = "Word Conqueror"
    case wordSmith = "Word Smith"
}

class Achievement {
    var name: AchievementName
    var desc: String
    var type: AchievementType
    var category: AchievementCategory
    var criteria: AchievementCriteria
    var actionTimestamps: [Date] = []
    var target: Int = 0
    
    init(
        name: AchievementName,
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
}

// MARK: - MODELS

struct AchievementUnlockedEvent: AnyEvent {
    var type: AchievementEventType
    var name: String
    var data: [String : Any]
    var timestamp: Date
    var anyType: AnyEventType { return type }
}


