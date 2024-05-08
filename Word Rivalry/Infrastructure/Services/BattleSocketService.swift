//
//  WebSocketService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-05.
//

import Foundation
import os.log
import SocketIO

typealias WordPath = [(Int, Int)]
typealias CodableWordPath = [[Int]]


class WordPathConverter {
    static func toCodable(wordPath: WordPath) -> CodableWordPath {
        return wordPath.map { [$0.0, $0.1] }
    }
    
    static func fromCodable(codableWordPath: CodableWordPath) -> WordPath {
        return codableWordPath.map { array -> (Int, Int) in
            guard array.count == 2 else {
                fatalError("Array must contain exactly two elements.")
            }
            return (array[0], array[1])
        }
    }
}

protocol BattleSocketService_InGame_Delegate: AnyObject {
    func didReceiveGameInformation(
        startTime: Date,
        endTime: Date,
        grid: [[Letter]],
        valid_words: [String],
        stats: GridStats
    )
    func didReceiveOpponentScore(_ score: Int)
}

protocol BattleSocketService_GameEnded_Delegate: AnyObject {
    func didReceiveGameResult(winner: String, playerResults: [PlayerResult])
}

// Authentication Struct
struct BattleServerAuthentication: Codable {
    let apiKey: String
    let playerID: String
    let playerName: String
    let gameID: String
}

// Generic GameMessage
protocol GameMessage: Codable {
    var id: String { get }
    var gameSessionUUID: String { get }
    var recipient: String { get }
    var timestamp: Int { get }
}

// Game Information Struct
struct GridStats: Codable {
    let difficulty_rating: Int
    let diversity_rating: Int
    let total_words: Int
}

struct GridInformation: Codable {
    let grid: [[Letter]]
    let valid_words: [String]
    let stats: GridStats
}

struct GameInformationPayload: Codable {
    let duration: Int
    let startTime: Date
    let endTime: Date
    let gridInformation: GridInformation
}

struct GameInformationMessage: GameMessage {
    let id: String
    let gameSessionUUID: String
    let recipient: String
    let timestamp: Int
    let payload: GameInformationPayload
}

// Opponent Score Update Struct
struct OpponentScoreUpdatePayload: Codable {
    let playerName: String
    let score: Int
}

struct OpponentScoreUpdateMessage: GameMessage {
    let id: String
    let gameSessionUUID: String
    let recipient: String
    let timestamp: Int
    let payload: OpponentScoreUpdatePayload
}

// Game Result Struct

// Define the Path as an array of tuples, each containing a Row and Col.



struct GameResultPayload: Codable {
    let winner: String
    let playerResults: [PlayerResult]
}

struct GameResultMessage: GameMessage {
    let id: String
    let gameSessionUUID: String
    let recipient: String
    let timestamp: Int
    let payload: GameResultPayload
}

enum BattleEvent: String, EventProtocol {
    // Auth
    case connectionSuccess = "CONNECTION_SUCCESS"
    case authenticate = "AUTHENTICATE"
    
    // Game update
    case gameInformation = "GAME_INFORMATION"
    case opponentPublishWord = "OPPONENT_PUBLISHED_WORD"
    case opponentLeft = "GAME_END_BY_PLAYER_LEFT"
    case gameResult = "GAME_RESULT"
    
    // Action
    case publishWord = "PUBLISH_WORD"
    case leaveGame = "LEAVE_GAME"
}


extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the BattleSocketService events from the app
    static let battleSocketService = Logger(subsystem: subsystem, category: "BattleSocketService")
}

class BattleSocketService {
    private let socketService: SocketIOService<BattleEvent>
    var inGameDelegate: BattleSocketService_InGame_Delegate?
    var gameEndedDelegate: BattleSocketService_GameEnded_Delegate?
    
    let apiKey: String = "4a7524be-0020-42c3-a259-cdc7208c5c7d"

    init() {
        guard let url = URL(string: "wss://battleserver-dtyigx66oa-nn.a.run.app") else {
            fatalError("Invalid URL")
        }
        
        socketService = SocketIOService(url: url)
        setupEventListeners()
    }
    
    func connect(gameID: String, userID: String, username: String) {
        self.socketService.connect(payload: [
            "apiKey" : apiKey,
            "gameID": gameID,
            "userID" : userID,
            "username" : username
        ])
    }
    
    func disconnect() {
        self.socketService.disconnect()
    }
    
    func status() -> SocketIOStatus? {
        self.socketService.status()
    }
    
    func isConnected() -> Bool {
        guard let status = self.socketService.status() else {
            return false
        }
        
        if status == .connected {
            return true
        }
        
        return false
    }
    
    func setInGameDelegate(_ delegate :BattleSocketService_InGame_Delegate) {
        self.inGameDelegate = delegate
    }
    
    func setGameEndedDelegate(_ delegate :BattleSocketService_GameEnded_Delegate) {
        self.gameEndedDelegate = delegate
    }
    
    func setupEventListeners() {
        socketService.onEvent(.connectionSuccess) { [weak self] data, ack in
            guard let strongSelf = self else {
                return
            }
            
            Logger.matchmakingSocketService.info("Connection success to matchmaking server")
        }
        
        socketService.onEvent(.gameInformation,
            decodeAs: GameInformationMessage.self,
            eventHandler: handleGameInformationMessage
        )
        
        socketService.onEvent(.opponentPublishWord,
            decodeAs: OpponentScoreUpdateMessage.self,
            eventHandler: handleOpponentScoreUpdate
        )
        
        socketService.onEvent(.opponentLeft) { data, ack in
            self.handleOpponentLeft()
        }
        
        socketService.onEvent(.gameResult,
            decodeAs: GameResultMessage.self,
            eventHandler: handleGameResult
        )
    }
}

// MARK: - Message sent
extension BattleSocketService {
    func leaveGame() {
        self.socketService.send(event: .leaveGame)
    }
    
    func sendScoreUpdate(wordPath: WordPath) {
        
        let codableWordPath = WordPathConverter.toCodable(
            wordPath: wordPath
        )
        
        self.socketService.send(
            event: .publishWord,
            codableObject: codableWordPath
        )
    }
}


// MARK: - Message received
extension BattleSocketService {
    
    private func handleGameInformationMessage(_ message: GameInformationMessage, _ ack: SocketAckEmitter) {
        Logger.battleSocketService.info("Received Game Information")
        let duration = message.payload.duration
        let startTime = message.payload.startTime
        let endTime = message.payload.endTime
        let grid = message.payload.gridInformation.grid
        let valid_words = message.payload.gridInformation.valid_words
        let stats = message.payload.gridInformation.stats
        inGameDelegate?.didReceiveGameInformation(
            startTime: startTime,
            endTime: endTime,
            grid: grid,
            valid_words: valid_words,
            stats: stats
        )
    }
    
    private func handleOpponentScoreUpdate(_ message: OpponentScoreUpdateMessage, _ ack: SocketAckEmitter) {
        Logger.battleSocketService.info("Received Opponent Score")
        let score = message.payload.score
        inGameDelegate?.didReceiveOpponentScore(score)
    }
    
    private func handleGameResult(_ message: GameResultMessage, _ ack: SocketAckEmitter) {
        Logger.battleSocketService.info("Received Game Result")
        let winner = message.payload.winner
        let playerResults = message.payload.playerResults
        gameEndedDelegate?.didReceiveGameResult(winner: winner, playerResults: playerResults)
    }
    
    private func handleOpponentLeft() {
        Logger.battleSocketService.info("ffffff - OP LEFT - Bad method")
    }
}
