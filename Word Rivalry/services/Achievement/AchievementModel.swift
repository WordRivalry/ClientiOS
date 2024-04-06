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

@Model
final class AchievementProgression {
    var name: String = ""
    var current: Int = 0
    var target: Int = 0
    
    @Transient
    var isComplete: Bool {
        return current >= target
    }
    
    @Transient
    var text: String {
        "\(self.current)/\(self.target) "
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
        print("Progressing \(self.name) by 1")
    }
    
    static var preview: [AchievementProgression] {
        let prog1 = AchievementProgression(name: AchievementName.ButtonClicker.rawValue, current: 5, target: 5)
        let prog3 = AchievementProgression(name: AchievementName.wordConqueror.rawValue, current: 1, target: 1)
        let prog4 = AchievementProgression(name: AchievementName.wordSmith.rawValue, current: 1, target: 5)
        return [prog1, prog3, prog4]
    }
}
