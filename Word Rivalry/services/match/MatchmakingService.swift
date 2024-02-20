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
//    let payload: JoinQueueSuccessPayload
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
enum ModeType: String, CaseIterable {
    case NORMAL = "NORMAL"
    case BLITZ = "BLITZ"
}

enum GameMode: String, CaseIterable {
    case RANK = "RANK"
    case QUICK_DUEL = "QUICK_DUEL"
}

enum MatchmakingMessage: String {
    // Sent
    case JOIN_QUEUE = "JOIN_QUEUE"
    case LEAVE_QUEUE = "LEAVE_QUEUE"
    
    // Received
    case JOIN_QUEUE_SUCCESS = "JOIN_QUEUE_SUCCESS"
    case JOIN_QUEUE_FAILURE = "JOIN_QUEUE_FAILURE"
    case MATCH_FOUND = "MATCH_FOUND"
}

enum MessageError: Error {
    case compositionFailed
}

class MatchmakingService: NSObject {
    static let shared = MatchmakingService()
    var webSocketTask: URLSessionWebSocketTask?
    var matchmakingDelegate: MatchmakingDelegate_onMatchFound?
    var matcMatchmakingDelegate_Searching: MatcMatchmakingDelegate_onSearch?
    var profileService: ProfileService?
    
    private override init() {
        super.init()
    }

    func connect() {
        guard let url = URL(string: "wss://matchmakingserver-dtyigx66oa-nn.a.run.app") else {
            matcMatchmakingDelegate_Searching?.didNotConnect()
            return
        }
        
        guard let profile = self.profileService else {
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("4a7524be-0020-42c3-a259-cdc7208c5c7d", forHTTPHeaderField: "x-api-key")
        request.addValue(profile.getUUID(), forHTTPHeaderField: "x-player-uuid")
        request.addValue(profile.getUsername(), forHTTPHeaderField: "x-player-username")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        listen()
        print("Connected to matchmaking server")
    }
    
    func setProfileService(_ profileService: ProfileService) {
        self.profileService = profileService
    }
    
    func setMatchmakingDelegate_onMatchFound(_ delegate :MatchmakingDelegate_onMatchFound) {
        self.matchmakingDelegate = delegate
    }
    
    func setMatchmakingDelegate(_ delegate :MatcMatchmakingDelegate_onSearch) {
        self.matcMatchmakingDelegate_Searching = delegate
    }
    
    func listen() {
         webSocketTask?.receive { [weak self] result in
             switch result {
             case .failure(let error):
                 print("Error in receiving message: \(error)")
             case .success(let message):
                 switch message {
                 case .string(let text):
                     self?.handleMessage(text)
                 default:
                     print("Received data message, which is not handled")
                 }
                 
                 // Keep listening for the next message
                 self?.listen()
             }
         }
     }
    
    func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            print("Failed to convert string to data.")
            return
        }

        guard let basicMessage = try? JSONDecoder().decode(BasicMessage.self, from: data) else {
            print("Failed to parse message or unknown message type.")
            return
        }
        
        switch basicMessage.type {
            case MatchmakingMessage.JOIN_QUEUE_SUCCESS.rawValue:
                if let decodedMessage = try? JSONDecoder().decode(JoinQueueSuccessMessage.self, from: data) {
                    handleJoinQueueSuccess(decodedMessage)
                }
            case MatchmakingMessage.JOIN_QUEUE_FAILURE.rawValue:
                if let decodedMessage = try? JSONDecoder().decode(JoinQueueFailureMessage.self, from: data) {
                    handleJoinQueueFailure(decodedMessage)
                }
            case MatchmakingMessage.MATCH_FOUND.rawValue:
                if let decodedMessage = try? JSONDecoder().decode(MatchFoundMessage.self, from: data) {
                    handleMatchFound(decodedMessage)
                }
            default:
                print("Unhandled message type: \(basicMessage.type)")
        }
    }
    
    func handleJoinQueueSuccess(_ message: JoinQueueSuccessMessage) {
        // Access the position from the message payload
//        let positionInQueue = message.payload.position

        // Update the application state or UI with this information
//        print("Successfully joined the queue. Position: \(positionInQueue)")

        print("JoinedQueue")
        
        // Notify the delegate
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
    }

}

extension MatchmakingService {
    /// Sends a message to start the matchmaking process.
    /// - Parameters:
    ///   - gameMode: The game mode for matchmaking.
    ///   - modeType: The mode type for matchmaking.
    /// - Throws: `MessageError.compositionFailed` if message composition fails.
    func findMatch(gameMode: GameMode, modeType: ModeType) throws {
        let message = try composeMessage(
            type: MatchmakingMessage.JOIN_QUEUE.rawValue,
            payload: ["gameMode": gameMode.rawValue, "modeType": modeType.rawValue, "elo": 1000]
        )
        send(message: message)
    }

    /// Sends a message to stop the matchmaking process.
    /// - Throws: `MessageError.compositionFailed` if message composition fails.
    func stopFindMatch() throws {
        let message = try composeMessage(type: MatchmakingMessage.LEAVE_QUEUE.rawValue)
        send(message: message)
    }
    
    /// Composes a message with optional payload.
    /// - Parameters:
    ///   - type: The type of message to be composed.
    ///   - payload: An optional dictionary containing message payload.
    /// - Returns: A stringified JSON representation of the message.
    /// - Throws: `MessageError.compositionFailed` if unable to compose the message.
    private func composeMessage(type: String, payload: [String: Any]? = nil) throws -> String {
        var dict: [String: Any] = ["type": type]
        
        if let additionalData = payload {
            dict["payload"] = additionalData
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw MessageError.compositionFailed
            }
            return jsonString
        } catch {
            throw error
        }
    }
    
    func send(message: String) {
        webSocketTask?.send(.string(message)) { [weak self] error in
            if let error = error {
                print("Error in sending message: \(error)")
                self?.matcMatchmakingDelegate_Searching?.didNotSendMessage()
            }
        }
    }
}


extension MatchmakingService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket did open")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket did close")
    }
}

