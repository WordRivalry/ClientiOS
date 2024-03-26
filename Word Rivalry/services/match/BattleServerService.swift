//
//  WebSocketService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-05.
//

import Foundation

protocol BattleServerDelegate_GameStartCountdown: AnyObject {
    func didReceivePreGameCountDown(countdown: Int)
}

protocol WebSocket_GameDelegate: AnyObject {
    func didReceiveGameInformation(duration: Int, grid: [[LetterTile]],  valid_words: [String], stats: GridStats)
    func didReceiveRemainingTime(_ remainingTime: Int)
    func didReceiveOpponentScore(_ score: Int)
    func didReceiveGameResult(winner: String, playerResults: [PlayerResult])
    func didReceiveOpponentLeft()
}

enum RankedGameMessageReceived: String, Codable {
    case GAME_INFORMATION = "GAME_INFORMATION"
    case PRE_GAME_COUNTDOWN = "PRE_GAME_COUNTDOWN"
    case COUNTDOWN = "COUNTDOWN"
    case OPPONENT_PUBLISHED_WORD = "OPPONENT_PUBLISHED_WORD"
    case GAME_END_BY_PLAYER_LEFT = "GAME_END_BY_PLAYER_LEFT"
    case GAME_RESULT = "GAME_RESULT"
}

// Generic GameMessage
protocol GameMessage: Codable {
    var id: String { get }
    associatedtype MessageType: RawRepresentable where MessageType.RawValue == String
    var type: MessageType { get }
    var gameSessionUUID: String { get }
    var recipient: String { get }
    var timestamp: Int { get }
}

// Message Type Struct
struct RankedGameMessageType: Codable {
    var type: RankedGameMessageReceived
}

// Game Information Struct

struct GridStats: Codable {
    let difficulty_rating: Int
    let diversity_rating: Int
    let total_words: Int
}

struct GameInformationPayload: Codable {
    let duration: Int
    let grid: [[LetterTile]]
    let valid_words: [String]
    let stats: GridStats
}

struct GameInformationMessage: GameMessage {
    let id: String
    var type: RankedGameMessageReceived
    let gameSessionUUID: String
    let recipient: String
    let timestamp: Int
    let payload: GameInformationPayload
}

// Pre Game Countdown Struct
struct PreGameCountdownPayload: Codable {
    let countdown: Int
}

struct PreGameCountdownMessage: GameMessage {
    let id: String
    var type: RankedGameMessageReceived
    let gameSessionUUID: String
    let recipient: String
    let timestamp: Int
    let payload: PreGameCountdownPayload
}

// Countdown Struct
struct CountdownPayload: Codable {
    let countdown: Int
}

struct CountdownMessage: GameMessage {
    let id: String
    var type: RankedGameMessageReceived
    let gameSessionUUID: String
    let recipient: String
    let timestamp: Int
    let payload: CountdownPayload
}

// Opponent Score Update Struct
struct OpponentScoreUpdatePayload: Codable {
    let playerName: String
    let score: Int
}

struct OpponentScoreUpdateMessage: GameMessage {
    let id: String
    var type: RankedGameMessageReceived
    let gameSessionUUID: String
    let recipient: String
    let timestamp: Int
    let payload: OpponentScoreUpdatePayload
}

// Game Result Struct

// Define the Path as an array of tuples, each containing a Row and Col.

struct WordHistory: Codable {
    let word: String
    let path: [[Int]]
    let time: Float
    let score: Int
}

struct PlayerResult: Codable, Identifiable {
    let playerName: String
    let playerEloRating: Int
    let score: Int
    let historic: [WordHistory]
    var id: String { playerName }
}

struct GameResultPayload: Codable {
    let winner: String
    let playerResults: [PlayerResult]
}

struct GameResultMessage: GameMessage {
    let id: String
    var type: RankedGameMessageReceived
    let gameSessionUUID: String
    let recipient: String
    let timestamp: Int
    let payload: GameResultPayload
}

class BattleServerService: WebSocketService {
    static let shared = BattleServerService()
    var gameDelegate: WebSocket_GameDelegate?
    var matchmakingDelegate: BattleServerDelegate_GameStartCountdown?
    
    private override init() {
        super.init()
    }
    
    func connect(gameSessionUUID: String) {
        guard let url = URL(string: "wss://battleserver-dtyigx66oa-nn.a.run.app") else { return }
        
        let playerUUID = try! PlayerDefaultsManager.shared.getUserUUID()
        let playerName = try! PlayerDefaultsManager.shared.getUsername()
        
        let headers = [
            "x-api-key": "4a7524be-0020-42c3-a259-cdc7208c5c7d",
            "x-game-session-uuid": gameSessionUUID,
            "x-player-uuid": playerUUID,
            "x-player-name": playerName
        ]
        
        super.connect(url: url, headers: headers)
    }
    
    func setGameDelegate(_ delegate :WebSocket_GameDelegate) {
        self.gameDelegate = delegate
    }
    
    func setMatchmakingDelegate(_ delegate :BattleServerDelegate_GameStartCountdown) {
        self.matchmakingDelegate = delegate
    }
    
    override func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            print("Failed to convert string to data.")
            return
        }
        
        print("\n \(data)")
        
        struct WrappedType: Codable {
            let type: RankedGameMessageReceived
        }
        
        do {
            let messageTypeWrapper = try JSONDecoder().decode(WrappedType.self, from: data)
            let messageType = messageTypeWrapper.type
            
            print("message type : \(messageType)")
            
            switch messageType {
            case .GAME_INFORMATION:
                let decodedMessage = try JSONDecoder().decode(GameInformationMessage.self, from: data)
                handleGameInformationMessage(decodedMessage)
            case .PRE_GAME_COUNTDOWN:
                let decodedMessage = try JSONDecoder().decode(PreGameCountdownMessage.self, from: data)
                handlePreGameCountdown(decodedMessage)
            case .COUNTDOWN:
                let decodedMessage = try JSONDecoder().decode(CountdownMessage.self, from: data)
                handleCountdown(decodedMessage)
                
            case .OPPONENT_PUBLISHED_WORD:
                let decodedMessage = try JSONDecoder().decode(OpponentScoreUpdateMessage.self, from: data)
                handleOpponentScoreUpdate(decodedMessage)
                
            case .GAME_RESULT:
                let decodedMessage = try JSONDecoder().decode(GameResultMessage.self, from: data)
                print("DECODED")
                handleGameResult(decodedMessage)
                
            case .GAME_END_BY_PLAYER_LEFT:
                handleOpponentLeft()
            }
        } catch {
            print("Failed to parse message type: \(error)")
            return
        }
        
    }
    
    override func handleDataMessage(_ data: Data) {
        // Intended to be overridden by subclasses
        fatalError("handleDataMessage(_:) has not been implemented")
    }
}

// MARK: - Message sent
extension BattleServerService {
    
    struct BasicMessage: Codable {
        let type: BattleServerMessage
    }
    
    enum PlayerActionMessage: String, Codable {
        case PUBLISH_WORD
    }
    
    enum BattleServerMessage: String, Codable {
        case PLAYER_ACTION
        case LEAVE_GAME_SESSION
    }
    
    struct ScoreUpdateMessage: Codable {
        let type: BattleServerMessage
        let payload: Payload
        
        struct Payload: Codable {
            let playerAction: PlayerActionMessage
            let data: WordPathData
            
            struct WordPathData: Codable {
                let wordPath: [[Int]]
            }
        }
    }
    
    func leaveGame() {
        send(BasicMessage(type: .LEAVE_GAME_SESSION))
    }
    
    func sendScoreUpdate(wordPath: [[Int]]) {
        let wordPathData = ScoreUpdateMessage.Payload.WordPathData(wordPath: wordPath)
        let payload = ScoreUpdateMessage.Payload(playerAction: .PUBLISH_WORD, data: wordPathData)
        let message = ScoreUpdateMessage(type: .PLAYER_ACTION, payload: payload)
        send(message)
    }
}


// MARK: - Message received
extension BattleServerService {
    
    private func handlePreGameCountdown(_ message: PreGameCountdownMessage) {
        let countdown = message.payload.countdown
        matchmakingDelegate?.didReceivePreGameCountDown(countdown: countdown)
    }
    
    private func handleGameInformationMessage(_ message: GameInformationMessage) {
        let duration = message.payload.duration
        let grid = message.payload.grid
        let valid_words = message.payload.valid_words
        let stats = message.payload.stats
        gameDelegate?.didReceiveGameInformation(duration: duration, grid: grid, valid_words: valid_words, stats: stats)
    }
    
    private func handleCountdown(_ message: CountdownMessage) {
        let countdown = message.payload.countdown
        gameDelegate?.didReceiveRemainingTime(countdown)
    }
    
    private func handleOpponentScoreUpdate(_ message: OpponentScoreUpdateMessage) {
        let score = message.payload.score
        gameDelegate?.didReceiveOpponentScore(score)
    }
    
    private func handleGameResult(_ message: GameResultMessage) {
        let winner = message.payload.winner
        let playerResults = message.payload.playerResults
        gameDelegate?.didReceiveGameResult(winner: winner, playerResults: playerResults)
    }
    
    private func handleOpponentLeft() {
        gameDelegate?.didReceiveOpponentLeft()
    }
}
