//
//  MatchmakingService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-19.
//

import Foundation
import OSLog
import SocketIO

protocol MatchmakingSocketService_Search_Delegate: AnyObject {
    func didNotConnect()
    func didJoinedQueue()
    func didNotJoinedQueue()
}

protocol MatchmakingSocketService_MatchFound_Delegate: AnyObject {
    func didFoundMatch(gameSessionUUID: String, opponentUsername: String, opponentElo: Int)
}

// Message Type
struct BasicMessage: Codable {
    let type: String
}

struct Authentication: Codable {
    let apiKey: String
    let playerID: String
    let playerName: String
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


enum MatchmakingEvent: String, EventProtocol {
    case connectionSuccess = "CONNECTION_SUCCESS"
    case authenticate = "AUTHENTICATE"
    case joinQueueSuccess = "JOIN_QUEUE_SUCCESS"
    case joinQueueFailure = "JOIN_QUEUE_FAILURE"
    case leftQueueSuccess = "LEFT_QUEUE_SUCCESS"
    case matchFound = "MATCH_FOUND"
    case joinQueue = "JOIN_QUEUE"
    case leaveQueue = "LEAVE_QUEUE"
}

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the MatchmakingService events from the app
    static let matchmakingSocketService = Logger(subsystem: subsystem, category: "MatchmakingSocketService")
}

class MatchmakingSocketService {
    private let socketService: SocketIOService<MatchmakingEvent>
    var searchDelegate: MatchmakingSocketService_Search_Delegate?
    var matchFoundDelegate: MatchmakingSocketService_MatchFound_Delegate?
 
    let apiKey: String = "4a7524be-0020-42c3-a259-cdc7208c5c7d"
    
    init() {
        guard let url = URL(string: "wss://matchmakingserver-dtyigx66oa-nn.a.run.app") else {
            fatalError("Invalid URL")
        }
        socketService = SocketIOService(url: url)
        setupEventListeners()
    }
    
    func connect(playerID: String, playerName: String) {
        self.socketService.connect(payload: [
            "apiKey" : apiKey,
            "playerID" : playerID,
            "playerName" : playerName
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
    
    func setupEventListeners() {
        socketService.onEvent(.connectionSuccess) { [weak self] data, ack in
            guard let strongSelf = self else {
                return
            }
            
            Logger.matchmakingSocketService.info("Connection success to matchmaking server")
        }
        
        socketService.onEvent(.joinQueueSuccess,
            decodeAs: JoinQueueSuccessMessage.self,
            eventHandler: handleJoinQueueSuccess
        )
        
        socketService.onEvent(.joinQueueFailure,
            decodeAs: JoinQueueFailureMessage.self,
            eventHandler: handleJoinQueueFailure
        )
        
        socketService.onEvent(.matchFound,
            decodeAs: MatchFoundMessage.self,
            eventHandler: handleMatchFound
        )  
        
        socketService.onEvent(.leftQueueSuccess) { data, ack in
            Logger.matchmakingSocketService.info("Left queue")
        }
    }
    
    func setSearchDelegate(_ delegate :MatchmakingSocketService_Search_Delegate) {
        self.searchDelegate = delegate
    }
    
    func setMatchFoundDelegate(_ delegate :MatchmakingSocketService_MatchFound_Delegate) {
        self.matchFoundDelegate = delegate
    }
}

// MARK: - Message received
extension MatchmakingSocketService {
    func handleJoinQueueSuccess(_ message: JoinQueueSuccessMessage, _ ack: SocketAckEmitter) {
        Logger.matchmakingSocketService.info("Joined matchmaking queue!")
        self.searchDelegate?.didJoinedQueue()
    }
    
    func handleJoinQueueFailure(_ message: JoinQueueFailureMessage, _ ack: SocketAckEmitter) {
        let errorCode = message.payload.errorCode
        Logger.matchmakingSocketService.error("Failed to joined queue. Error Code: \(errorCode)")
        self.searchDelegate?.didNotJoinedQueue()
    }
    
    func handleMatchFound(_ message: MatchFoundMessage, _ ack: SocketAckEmitter) {
        
        Logger.matchmakingSocketService.info("Match found!")
        
        let gameSessionUUID = message.payload.gameSessionId
        let opponentUsername = message.payload.opponent.opponentUsername
        let opponentElo = message.payload.opponent.opponentElo
        self.matchFoundDelegate?.didFoundMatch(
            gameSessionUUID: gameSessionUUID,
            opponentUsername: opponentUsername,
            opponentElo: opponentElo
        )
        self.socketService.disconnect()
    }
}


// MARK: - Message Sent
extension MatchmakingSocketService {

    struct JoinQueuePayload: Codable {
        let gameMode: GameMode
        let modeType: ModeType
        let elo: Int
    }
    
    func findMatch(gameMode: GameMode, modeType: ModeType, eloRating: Int) throws {
        let payload = JoinQueuePayload(gameMode: gameMode, modeType: modeType, elo: eloRating)
        
        self.socketService.send(
            event:.joinQueue,
            codableObject: payload
        )
    }
    
    func stopFindMatch() {
        self.socketService.send(event: .leaveQueue)
        self.socketService.disconnect()
    }
}
