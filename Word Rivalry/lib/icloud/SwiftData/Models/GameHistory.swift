//
//  GameHistory.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import SwiftData

@Model
class GameHistory {
    let ownScore: Int = 0
    let opponentRecordID: String = ""
    let opponentScore: Int = 0
    let wasForfeited = false
    
    init(ownScore: Int = 0, opponentRecordID: String = "", opponentScore: Int = 0, wasForfeited: Bool = false) {
        self.ownScore = ownScore
        self.opponentRecordID = opponentRecordID
        self.opponentScore = opponentScore
        self.wasForfeited = wasForfeited
    }
    
    static var preview: GameHistory {
        GameHistory(ownScore: 1223, opponentRecordID: "123", opponentScore: 1201)
    }
    
    static var previews: [GameHistory] {
        [
            GameHistory.preview,
            GameHistory(ownScore: 1223, opponentRecordID: "Van Helsing", opponentScore: 1201),
            GameHistory(ownScore: 976, opponentRecordID: "Van Helsing", opponentScore: 1245),
            GameHistory(ownScore: 374, opponentRecordID: "Van Helsing", opponentScore: 875),
            GameHistory(ownScore: 476, opponentRecordID: "Van Helsing", opponentScore: 569, wasForfeited: true),
            GameHistory(ownScore: 780, opponentRecordID: "Van Helsing", opponentScore: 873),
            GameHistory(ownScore: 1345, opponentRecordID: "Van Helsing", opponentScore: 1745),
            GameHistory(ownScore: 1663, opponentRecordID: "Van Helsing", opponentScore: 2143),
            GameHistory(ownScore: 864, opponentRecordID: "Van Helsing", opponentScore: 1532),
            GameHistory(ownScore: 842, opponentRecordID: "Van Helsing", opponentScore: 1234, wasForfeited: true),
            GameHistory(ownScore: 1496, opponentRecordID: "Van Helsing", opponentScore: 753),
            GameHistory(ownScore: 946, opponentRecordID: "Van Helsing", opponentScore: 234)
        ]
    }
}
