//
//  AchievementProgression.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import Foundation
import SwiftData
import os.log

@Model
final class AchievementProgression {
    var name: String = ""
    var current: Int = 0
    var target: Int = 0
    
    @Transient
    private let logger = Logger(subsystem: "SwiftData", category: "AchievementProgression")
    
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
        
        self.logger.debug("Achievement progression [\(self.name)] was instanciated")
    }
    
    func progress(by: Int) {
        current += 1
        self.logger.debug("Progressing [\(self.name)] by 1")
    }
    
    static var preview: [AchievementProgression] {
        let prog1 = AchievementProgression(name: AchievementName.ButtonClicker.rawValue, current: 5, target: 5)
        let prog3 = AchievementProgression(name: AchievementName.wordConqueror.rawValue, current: 1, target: 1)
        let prog4 = AchievementProgression(name: AchievementName.wordSmith.rawValue, current: 1, target: 5)
        return [prog1, prog3, prog4]
    }
}
