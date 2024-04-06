//
//  AchievementsProgression.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-05.
//

import Foundation
import os.log

@Observable final class AchievementsProgression {
    let progressions: [AchievementProgression]
    
    private let logger = Logger(subsystem: "com.WordRivalry", category: "AchievementsProgression")
    
    init(progressions: [AchievementProgression]) {
        self.progressions = progressions
    }
    
    static var preview: AchievementsProgression {
        AchievementsProgression(progressions: AchievementProgression.preview)
    }
    
    func isUnlocked(for achievementName: AchievementName) -> Bool {
        guard let prog = progressions.first(where: { achievementProgression in
            achievementProgression.name == achievementName.rawValue
        })
        else { return true }
        return prog.isComplete
    }
    
    func getProgression(for achievementName: AchievementName) -> AchievementProgression {
        guard let progression = progressions.first(where: { achievementProgression in
            achievementProgression.name == achievementName.rawValue
        })
        else { fatalError("No progression found")}
        return progression
    }
}
