//
//  GameHistory.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import SwiftData

@Model final class MatchHistoric: DataPreview {
    static var preview: MatchHistoric = MatchHistoric(
            gameID: "123456789",
            ownScore: 2243,
            opponentRecordID: "123",
            opponentScore: 2123
        )
    
    /// The game session stable identifier
    var gameID: String = ""
    
    /// The score the player got
    var ownScore: Int = 0
    
    /// Opponent stable identifier
    var opponentRecordID: String = ""
    
    /// The opponent name at the time of the match
    var thenOpponentName: String = ""
    
    /// The score the opponent got during the match
    var opponentScore: Int = 0
    
    init(
        gameID: String,
        ownScore: Int = 0,
        opponentRecordID: String = "",
        opponentScore: Int = 0
    ) {
        self.gameID = gameID
        self.ownScore = ownScore
        self.opponentRecordID = opponentRecordID
        self.opponentScore = opponentScore
    }

    static var previews: [MatchHistoric] {
        [
            MatchHistoric.preview,
            MatchHistoric(
                gameID: "2745656234235",
                ownScore: 1223,
                opponentRecordID: "123",
                opponentScore: 1201
            ),
            MatchHistoric(
                gameID: "98562435235",
                ownScore: 976,
                opponentRecordID: "Van Helsing", 
                opponentScore: 1245
            ),
            MatchHistoric(
                gameID: "8956845634536",
                ownScore: 374,
                opponentRecordID: "Van Helsing", 
                opponentScore: 875
            ),
            MatchHistoric(
                gameID: "86547356346",
                ownScore: 476,
                opponentRecordID: "Van Helsing",
                opponentScore: 569
            ),
            MatchHistoric(
                gameID: "868756346",
                ownScore: 780,
                opponentRecordID: "Van Helsing",
                opponentScore: 873),
            MatchHistoric(
                gameID: "345346873",
                ownScore: 1345,
                opponentRecordID: "Van Helsing",
                opponentScore: 1745
            ),
            MatchHistoric(
                gameID: "327358823",
                ownScore: 1663,
                opponentRecordID: "Van Helsing",
                opponentScore: 2143
            ),
            MatchHistoric(
                gameID: "998321134",
                ownScore: 864,
                opponentRecordID: "Van Helsing",
                opponentScore: 1532
            ),
            MatchHistoric(
                gameID: "16549064252",
                ownScore: 842,
                opponentRecordID: "Van Helsing",
                opponentScore: 1234
            ),
            MatchHistoric(
                gameID: "14368465231",
                ownScore: 1496,
                opponentRecordID: "Van Helsing",
                opponentScore: 753
            ),
            MatchHistoric(
                gameID: "12312357468",
                ownScore: 946,
                opponentRecordID: "Van Helsing", 
                opponentScore: 234
            )
        ]
    }
}
