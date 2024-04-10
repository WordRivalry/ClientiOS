//
//  MatchmakingService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-19.
//

import Foundation
import os.log

protocol MatcMatchmakingDelegate: AnyObject {
    func didNotConnect()
    func didJoinedQueue()
    func didNotJoinedQueue()
    func didFoundMatch(gameSessionUUID: String, opponentUsername: String, opponentElo: Int)
}

// Message Type
struct BasicMessage: Codable {
    let type: String
}

// Joined Queue Success
struct JoinQueueSuccessPayload: Codable {
    let position: Int
}
struct JoinQueueSuccessMessage: Codable {
    let type: String
}

// Joined Queue Failure
struct JoinQueueFailurePayload: Codable {
    let errorCode: Int
}
struct JoinQueueFailureMessage: Codable {
    let type: String
    let payload: JoinQueueFailurePayload
}

// Match Found
struct OpponentData: Codable {
    let opponentUsername: String
    let opponentElo: Int
}

struct MatchFoundPayload: Codable {
    let gameSessionId: String
    let opponent: OpponentData
}

struct MatchFoundMessage: Codable {
    var type: String
    let payload: MatchFoundPayload
}

// Enums
enum ModeType: String, CaseIterable, Codable {
    case NORMAL = "NORMAL"
    case BLITZ = "BLITZ"
}

enum GameMode: String, CaseIterable, Codable {
    case RANK = "RANK"
    case QUICK_DUEL = "QUICK_DUEL"
}

class MatchmakingService: WebSocketService {
    static let shared = MatchmakingService()
    var webSocketTask: URLSessionWebSocketTask?
    var matchmakingDelegate: MatcMatchmakingDelegate?
    private let logger = Logger(subsystem: "com.WordRivalry", category: "MatchmakingService")
    
    private override init() {
        super.init()
    }
    
    func connect(playerName: String, playerUUID: String) throws {
        guard let url = URL(string: "wss://matchmakingserver-dtyigx66oa-nn.a.run.app") else { return }
        let headers = [
            "x-api-key": "4a7524be-0020-42c3-a259-cdc7208c5c7d",
            "x-player-uuid": playerUUID,
            "x-player-name": playerName
        ]
        
        super.connect(url: url, headers: headers)
    }
    
    func setMatchmakingDelegate(_ delegate :MatcMatchmakingDelegate) {
        self.matchmakingDelegate = delegate
    }
    
    enum MatchmakingMessageReceived: String, Codable {
        case CONNECTION_SUCCESS = "CONNECTION_SUCCESS"
        case JOIN_QUEUE_SUCCESS = "JOIN_QUEUE_SUCCESS"
        case JOIN_QUEUE_FAILURE = "JOIN_QUEUE_FAILURE"
        case LEFT_QUEUE_SUCCESS = "LEFT_QUEUE_SUCCESS"
        case MATCH_FOUND = "MATCH_FOUND"
      
    }
    
    override func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            self.logger.error("Failed to convert string to data.")
            return
        }
                
        struct WrappedType: Codable {
            let type: MatchmakingMessageReceived
        }
        
        do {
            
            do {
                // Decode the JSON data to a generic Swift type (e.g., [String: Any])
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let jsonDictionary = jsonObject as? [String: Any] {
                    self.logger.debug("Decoded JSON: \(jsonDictionary)")
                } else {
                    self.logger.error("JSON is not a dictionary")
                }
            } catch {
                self.logger.error("Failed to decode JSON: \(error.localizedDescription)")
            }
            
            let messageTypeWrapper = try JSONDecoder().decode(WrappedType.self, from: data)
            let messageType = messageTypeWrapper.type
            
            self.logger.debug("message type : \(messageType.rawValue)")
            
            switch messageType {
            case .CONNECTION_SUCCESS:
                self.logger.info("Connection success to matchmaking server")
            case .JOIN_QUEUE_SUCCESS:
                if let decodedMessage = try? JSONDecoder().decode(JoinQueueSuccessMessage.self, from: data) {
                    handleJoinQueueSuccess(decodedMessage)
                }
            case .JOIN_QUEUE_FAILURE:
                if let decodedMessage = try? JSONDecoder().decode(JoinQueueFailureMessage.self, from: data) {
                    handleJoinQueueFailure(decodedMessage)
                }
            case .MATCH_FOUND:
                if let decodedMessage = try? JSONDecoder().decode(MatchFoundMessage.self, from: data) {
                    handleMatchFound(decodedMessage)
                }
            case .LEFT_QUEUE_SUCCESS:
                self.logger.info("Left queue")
            }
        } catch {
            self.logger.error("Failed to parse message type: \(error)")
            return
        }
    }
}



// MARK: - Message received
extension MatchmakingService {
    func handleJoinQueueSuccess(_ message: JoinQueueSuccessMessage) {
        self.logger.info("Joined matchmaking queue!")
        self.matchmakingDelegate?.didJoinedQueue()
    }

    func handleJoinQueueFailure(_ message: JoinQueueFailureMessage) {
        let errorCode = message.payload.errorCode
        self.logger.error("Failed to joined queue. Error Code: \(errorCode)")
        self.matchmakingDelegate?.didNotJoinedQueue()
    }
    
    func handleMatchFound(_ message: MatchFoundMessage) {
        
        self.logger.info("Match found!")
        
        let gameSessionUUID = message.payload.gameSessionId
        let opponentUsername = message.payload.opponent.opponentUsername
        let opponentElo = message.payload.opponent.opponentElo
        self.matchmakingDelegate?.didFoundMatch(
            gameSessionUUID: gameSessionUUID,
            opponentUsername: opponentUsername,
            opponentElo: opponentElo
        )
        self.disconnect()
    }
}


// MARK: - Message Sent
extension MatchmakingService {
    
    enum MatchmakingMessageSend: String, Codable  {
        case JOIN_QUEUE = "JOIN_QUEUE"
        case LEAVE_QUEUE = "LEAVE_QUEUE"
    }
    
    struct JoinQueueRequest: Codable {
        var type: MatchmakingMessageSend = .JOIN_QUEUE
        let payload: Payload
        
        struct Payload: Codable {
            let gameMode: GameMode
            let modeType: ModeType
            let elo: Int
        }
    }
    
    struct LeaveQueueRequest: Codable {
        var type: MatchmakingMessageSend = .LEAVE_QUEUE
    }
    
    func findMatch(gameMode: GameMode, modeType: ModeType, eloRating: Int) throws {
        let payload = JoinQueueRequest.Payload(gameMode: gameMode, modeType: modeType, elo: eloRating)
        let message = JoinQueueRequest(payload: payload)
        send(message)
    }

    func stopFindMatch() throws {
        let message = LeaveQueueRequest()
        send(message)
        self.disconnect()
    }
}
