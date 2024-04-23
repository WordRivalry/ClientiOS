//
//  GameHistory.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import SwiftData

// MARK: MatchRecord
@Model final class MatchRecord: DataPreview {

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
        thenOpponentName: String = "",
        opponentRecordID: String = "",
        opponentScore: Int = 0
    ) {
        self.gameID = gameID
        self.ownScore = ownScore
        self.thenOpponentName = thenOpponentName
        self.opponentRecordID = opponentRecordID
        self.opponentScore = opponentScore
    }
    
    // MARK: DataPreview
    
    static var nullData: MatchRecord = MatchRecord(
            gameID: "",
            ownScore: 0,
            thenOpponentName: "",
            opponentRecordID: "",
            opponentScore: 0
        )
    
    static var preview: MatchRecord = MatchRecord(
            gameID: "123456789",
            ownScore: 2243,
            thenOpponentName: "DarKLight266",
            opponentRecordID: "123",
            opponentScore: 2123
        )

    static var previews: [MatchRecord] {
        [
            MatchRecord(
                   gameID: "123456789",
                   ownScore: 2243,
                   thenOpponentName: "DarKLight266",
                   opponentRecordID: "123",
                   opponentScore: 2123
            ),
            MatchRecord(
                gameID: "2745656234235",
                ownScore: 1223,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "123",
                opponentScore: 1201
            ),
            MatchRecord(
                gameID: "98562435235",
                ownScore: 976,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 1245
            ),
            MatchRecord(
                gameID: "8956845634536",
                ownScore: 374,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 875
            ),
            MatchRecord(
                gameID: "86547356346",
                ownScore: 476,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 569
            ),
            MatchRecord(
                gameID: "868756346",
                ownScore: 780,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 873),
            MatchRecord(
                gameID: "345346873",
                ownScore: 1345,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 1745
            ),
            MatchRecord(
                gameID: "327358823",
                ownScore: 1663,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 2143
            ),
            MatchRecord(
                gameID: "998321134",
                ownScore: 864,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 1532
            ),
            MatchRecord(
                gameID: "16549064252",
                ownScore: 842,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 1234
            ),
            MatchRecord(
                gameID: "14368465231",
                ownScore: 1496,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 753
            ),
            MatchRecord(
                gameID: "12312357468",
                ownScore: 946,
                thenOpponentName: "Dark Vlad",
                opponentRecordID: "Van Helsing",
                opponentScore: 234
            )
        ]
    }
}
