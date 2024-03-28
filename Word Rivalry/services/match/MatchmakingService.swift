//
//  MatchmakingService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-19.
//

import Foundation

protocol MatchmakingDelegate_onMatchFound: AnyObject {
    func didFoundMatch(gameSessionUUID: String, opponentUsername: String, opponentElo: Int)
}

protocol MatcMatchmakingDelegate_onSearch: AnyObject {
    func didNotConnect()
    func didNotSendMessage()
    func didJoinedQueue()
    func didNotJoinedQueue()
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
    var matchmakingDelegate: MatchmakingDelegate_onMatchFound?
    var matcMatchmakingDelegate_Searching: MatcMatchmakingDelegate_onSearch?
    
    private override init() {
        super.init()
    }
    
    func connect() throws {
        guard let url = URL(string: "wss://matchmakingserver-dtyigx66oa-nn.a.run.app") else { return }
        
        let playerUUID = LocalProfile.shared.getProfile().userRecordID
        let playerName = LocalProfile.shared.getProfile().playerName
        
        let headers = [
            "x-api-key": "4a7524be-0020-42c3-a259-cdc7208c5c7d",
            "x-player-uuid": playerUUID,
            "x-player-name": playerName
        ]
        
        super.connect(url: url, headers: headers)
    }
    
    func setMatchmakingDelegate_onMatchFound(_ delegate :MatchmakingDelegate_onMatchFound) {
        self.matchmakingDelegate = delegate
    }
    
    func setMatchmakingDelegate(_ delegate :MatcMatchmakingDelegate_onSearch) {
        self.matcMatchmakingDelegate_Searching = delegate
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
            print("Failed to convert string to data.")
            return
        }
        
        print("\n \(data)")
        
        struct WrappedType: Codable {
            let type: MatchmakingMessageReceived
        }
        
        do {
            let messageTypeWrapper = try JSONDecoder().decode(WrappedType.self, from: data)
            let messageType = messageTypeWrapper.type
            
            print("message type : \(messageType)")
            
            switch messageType {
            case .CONNECTION_SUCCESS:
                print("Connection success to matchmaking server")
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
                print("Left queue")
            }
        } catch {
            print("Failed to parse message type: \(error)")
            return
        }
    }
}



// MARK: - Message received
extension MatchmakingService {
    func handleJoinQueueSuccess(_ message: JoinQueueSuccessMessage) {
        self.matcMatchmakingDelegate_Searching?.didJoinedQueue()
    }

    
    func handleJoinQueueFailure(_ message: JoinQueueFailureMessage) {
        // Access the code from the message payload
        let errorCode = message.payload.errorCode
        
        // Update the application state or UI with this information
        print("Failed to joined queue. Error Code: \(errorCode)")
        
        // Notify the delegate
        self.matcMatchmakingDelegate_Searching?.didNotJoinedQueue()
    }
    
    func handleMatchFound(_ message: MatchFoundMessage) {
        
        print("Did found match")
        
        // Access GameSessionUUID from the message payload
        let gameSessionUUID = message.payload.gameSessionId
        
        // Access opponentUsername from the message payload
        let opponentUsername = message.payload.opponent.opponentUsername
        
        // Access opponentElo from the message payload
        let opponentElo = message.payload.opponent.opponentElo
        
        // Now that we have successfully unwrapped the JSON, call the delegate method
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
    
    func findMatch(gameMode: GameMode, modeType: ModeType) throws {
        let payload = JoinQueueRequest.Payload(gameMode: gameMode, modeType: modeType, elo: 1000)
        let message = JoinQueueRequest(payload: payload)
        send(message)
    }

    func stopFindMatch() throws {
        let message = LeaveQueueRequest()
        send(message)
        self.disconnect()
    }
}
