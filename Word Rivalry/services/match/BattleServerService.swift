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
    func didReceiveRoundStart(roundNumber: Int, duration: Int, grid: [[LetterTile]])
    func didUpdateTime(_ remainingTime: Int)
    func didEndRound(round: Int, playerScore: Int, opponentScore: Int, winner: String)
    func didUpdateOpponentScore(_ score: Int)
    func didReceiveGameEnd(winners: [String], winnerStatus: String)
}

enum BattleServerMessage: String {
    // Sent
    case JOIN_GAME_SESSION = "JOIN_GAME_SESSION"
    case LEAVE_GAME_SESSION = "LEAVE_GAME_SESSION"
    case PLAYER_ACTION = "PLAYER_ACTION"

    
    // Received
    case gameStartCountdown = "gameStartCountdown"
    case roundStart = "roundStart"
    case timeUpdate = "timeUpdate"
    case opponentScoreUpdate = "opponentScoreUpdate"
    case endRound = "endRound"
    case gameEnd = "gameEnd"
}

enum PlayerActionMessage: String {
    case PUBLISH_WORD = "PUBLISH_WORD"
}



extension LetterTile {
    static func from(_ dictionary: [String: Any]) -> LetterTile? {
        guard let letter = dictionary["letter"] as? String,
              let score = dictionary["score"] as? Int else { return nil }
        
        let letterMultiplier = dictionary["letterMultiplier"] as? Int ?? 1
        let wordMultiplier = dictionary["wordMultiplier"] as? Int ?? 1
        
        return LetterTile(letter: letter, score: score, letterMultiplier: letterMultiplier, wordMultiplier: wordMultiplier)
    }
}

class BattleServerService: NSObject {
    static let shared = BattleServerService()
    var webSocketTask: URLSessionWebSocketTask?
    var profileService: ProfileService?
    var gameDelegate: WebSocket_GameDelegate?
    var matchmakingDelegate: BattleServerDelegate_GameStartCountdown?
    var gameSessionUUID: String?
    
    private override init() {
          super.init()
      }

    func connect(gameSessionUUID: String) {
        
        self.setGameSessionUUID(gameSessionUUID: gameSessionUUID)
        
        guard let profile = self.profileService else {
            return
        } 
        
        guard let sessionUUID = self.gameSessionUUID else {
            return
        } 
        
        guard let url = URL(string: "ws://battleserver-dtyigx66oa-nn.a.run.app") else { return }
        var request = URLRequest(url: url)
        request.addValue("4a7524be-0020-42c3-a259-cdc7208c5c7d", forHTTPHeaderField: "x-api-key")
        request.addValue(sessionUUID, forHTTPHeaderField: "x-game-session-uuid")
        request.addValue(profile.getUUID(), forHTTPHeaderField: "x-player-uuid")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        listen()
    }
    
    func setGameDelegate(_ delegate :WebSocket_GameDelegate) {
        self.gameDelegate = delegate
    }
    
    func setProfileService(_ profileService: ProfileService) {
        self.profileService = profileService
    }
    
    func setMatchmakingDelegate(_ delegate :BattleServerDelegate_GameStartCountdown) {
        self.matchmakingDelegate = delegate
    }
    
    func setGameSessionUUID(gameSessionUUID: String) {
        self.gameSessionUUID = gameSessionUUID
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
        // Parse the JSON string and handle different message types
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            print("Failed to parse message or unknown message type")
            return
        }
        
        switch type {
        case BattleServerMessage.roundStart.rawValue:
            handleRoundStartMessage(json)
        case BattleServerMessage.timeUpdate.rawValue:
            handleTimeUpdate(json)
        case BattleServerMessage.endRound.rawValue:
            handleEndRound(json)
        case BattleServerMessage.opponentScoreUpdate.rawValue:
            handleOpponentScoreUpdate(json)
        case BattleServerMessage.gameStartCountdown.rawValue:
            handlePreGameCountdown(json)
        case BattleServerMessage.gameEnd.rawValue:
            print("Game ended: \(json)")
//            
//        case "gameStart":
//                if let startTime = json["startTime"] as? Int64,
//                   let duration = json["duration"] as? Int,
//                   let gridArray = json["grid"] as? [[[String: Any]]] {
//                    let grid = gridArray.map { row -> [LetterTile] in
//                        row.compactMap { LetterTile.from($0) }
//                    }
//                    matchmakingDelegate?.didReceiveGameReadyToStart(startTime: startTime, duration: duration, grid: grid)
//                }
        default:
            print("Unhandled message type: \(type)")
        }
    }
    
    func send(message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("Error in sending message: \(error)")
            }
        }
    }
}

extension BattleServerService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket did open")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket did close")
    }
}

extension BattleServerService {

    // Acknowledge that the game can start
    func joinGameSession() {
        let message = composeMessage(type: BattleServerMessage.JOIN_GAME_SESSION.rawValue)
        send(message: message)
    }
    
    func leaveGameSession() {
        let message = composeMessage(type: BattleServerMessage.LEAVE_GAME_SESSION.rawValue)
        send(message: message)
    }

//    {
//        "id": "0acb9eb1-ada8-46d0-8496-0a4c0f6c622b",
//        "type": "gameStartCountdown",
//        "payload": 3,
//        "timestamp": 1707374802913,
//        "recipient": "all"
//    }
    private func handlePreGameCountdown(_ json: [String: Any]) {
        print("Received countdown: \(json)")
        // Extract the countdown value from the "payload" key
        if let countdown = json["payload"] as? Int {
            matchmakingDelegate?.didReceivePreGameCountDown(countdown: countdown)
        }
    }
    
    func handleRoundStartMessage(_ json: [String: Any]) {
        guard let payload = json["payload"] as? [String: Any],
              let rounds = payload["round"] as? Int,
              let duration = payload["duration"] as? Int,
              let gridArray = payload["grid"] as? [[[String: Any]]] else {
            print("Invalid JSON structure")
            return
        }

        var grid: [[LetterTile]] = []

        for row in gridArray {
            var letterRow: [LetterTile] = []
            for tileDict in row {
                var modifiedDict = tileDict
                // Adjust keys to match the LetterTile.from(_) expectations
                modifiedDict["score"] = modifiedDict.removeValue(forKey: "value")
                modifiedDict["letterMultiplier"] = modifiedDict.removeValue(forKey: "multiplierLetter")
                modifiedDict["wordMultiplier"] = modifiedDict.removeValue(forKey: "multiplierWord")

                guard let tile = LetterTile.from(modifiedDict) else { fatalError("LetterTile Parsing Error, at roundStart handler") }
                letterRow.append(tile)
            }
            grid.append(letterRow)
        }
        
        gameDelegate?.didReceiveRoundStart(roundNumber: rounds, duration: duration, grid: grid);
    }
    
//    {
//        "id": "28154959-4cdb-43b5-837c-9dbf07709899",
//        "type": "timeUpdate",
//        "payload": 2997,
//        "timestamp": 1707374806920,
//        "recipient": "all"
//    }
    private func handleTimeUpdate(_ json: [String: Any]) {
        print("Received remainingTime: \(json)")
        guard let remainingTime = json["payload"] as? Int else { fatalError("handleTimeUpdate no payload key") }
        gameDelegate?.didUpdateTime(remainingTime)
    }
    
    
//    {
//        "id": "3de87ae8-7da8-41b1-a73e-9680b48ab839",
//        "type": "opponentScoreUpdate",
//        "payload": {
//            "playerUuid": "232323-232323-232323",
//            "newScore": 3
//        },
//        "timestamp": 1707374807292,
//        "recipient": [
//            "121212-121212-121212"
//        ]
//    }
    private func handleOpponentScoreUpdate(_ json: [String: Any]) {
        print("Opponent score update: \(json)")
        // First, extract the "payload" dictionary
        if let payload = json["payload"] as? [String: Any],
           // Then, extract the "newScore" from within the payload
           let newScore = payload["newScore"] as? Int {
            // Now that you have the newScore correctly, update the opponent's score
            gameDelegate?.didUpdateOpponentScore(newScore)
        }
    }

    
//    {
//        "id": "288d2512-479d-40c5-8304-a3a07aa6fdd4",
//        "type": "endRound",
//        "payload": {
//            "round": 0,
//            "yourScore": 0,
//            "opponentScoreTotal": 3,
//            "winner": "Opponent"
//        },
//        "timestamp": 1707374809923,
//        "recipient": "121212-121212-121212"
//    }
    private func handleEndRound(_ json: [String: Any]) {
        print("End of round: \(json)")
        // Extract the 'payload' dictionary first
        guard let payload = json["payload"] as? [String: Any],
              let round = payload["round"] as? Int,
              let playerScore = payload["yourScore"] as? Int, // Map 'yourScore' to playerScore
              let opponentScore = payload["opponentScoreTotal"] as? Int, // Map 'opponentScoreTotal' to opponentScore
              let winner = payload["winner"] as? String else {
            print("Invalid or incomplete 'endRound' message format.")
            return
        }
        gameDelegate?.didEndRound(round: round, playerScore: playerScore, opponentScore: opponentScore, winner: winner)
    }
    
    
    private func handleGameEndMessage(_ json: [String: Any]) {
        // Extract the 'payload' dictionary first
        guard let payload = json["payload"] as? [String: Any],
              let winnerInfo = payload["winner"] as? [String: Any],
              let status = winnerInfo["status"] as? String,
              let winners = winnerInfo["winners"] as? [String] else {
            print("Invalid or incomplete 'gameEnd' message format.")
            return
        }
        
        // Assuming your gameDelegate has a method like didReceiveGameEnd(winners:winnerStatus:)
        gameDelegate?.didReceiveGameEnd(winners: winners, winnerStatus: status)
    }
    
    // Helper method to compose a generic message with optional additional data
    private func composeMessage(type: String, data: [String: Any]? = nil) -> String {
        var dict: [String: Any] = ["type": type]
        if let additionalData = data {
            for (key, value) in additionalData {
                dict[key] = value
            }
        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            print("Error composing \(type) message")
            return ""
        }
    }

    
    func sendScoreUpdate(wordPath: [[Int]]) {
        
        let dataDict: [String: Any] = [ "wordPath": wordPath ]
        
        let payloadDict: [String: Any] = [
            "playerAction": PlayerActionMessage.PUBLISH_WORD.rawValue,
            "data": dataDict
        ]
        
         let messageDict: [String: Any] = [
            "type": BattleServerMessage.PLAYER_ACTION.rawValue,
            "payload":payloadDict
         ]
         
         send(dictionary: messageDict)
     }
     
     // Utility method to send a message given a dictionary
     private func send(dictionary: [String: Any]) {
         if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
            let jsonString = String(data: jsonData, encoding: .utf8) {
             send(message: jsonString)
         } else {
             print("Error serializing message")
         }
     }
    
    func quitGame() {
        let messageDict: [String: Any] = [
            "type": "quitGame"
        ]
        send(dictionary: messageDict)
    }
}



// MARK: Example of roundStart
//
//{
//    "id": "d0788d6e-83a1-414d-ab4a-e336d1ab1a5f",
//    "type": "roundStart",
//    "payload": {
//        "round": 1,
//        "duration": 5000,
//        "grid": [
//            [
//                {
//                    "letter": "U",
//                    "value": 1,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                },
//                {
//                    "letter": "E",
//                    "value": 1,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                },
//                {
//                    "letter": "L",
//                    "value": 1,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                },
//                {
//                    "letter": "L",
//                    "value": 1,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                }
//            ],
//            [
//                {
//                    "letter": "Y",
//                    "value": 6,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                },
//                {
//                    "letter": "R",
//                    "value": 1,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                },
//                {
//                    "letter": "D",
//                    "value": 2,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                },
//                {
//                    "letter": "C",
//                    "value": 2,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 2
//                }
//            ],
//            [
//                {
//                    "letter": "S",
//                    "value": 2,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                },
//                {
//                    "letter": "C",
//                    "value": 2,
//                    "multiplierLetter": 2,
//                    "multiplierWord": 1
//                },
//                {
//                    "letter": "T",
//                    "value": 1,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 2
//                },
//                {
//                    "letter": "Z",
//                    "value": 7,
//                    "multiplierLetter": 2,
//                    "multiplierWord": 2
//                }
//            ],
//            [
//                {
//                    "letter": "K",
//                    "value": 8,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                },
//                {
//                    "letter": "X",
//                    "value": 6,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 2
//                },
//                {
//                    "letter": "P",
//                    "value": 2,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 2
//                },
//                {
//                    "letter": "Z",
//                    "value": 7,
//                    "multiplierLetter": 1,
//                    "multiplierWord": 1
//                }
//            ]
//        ]
//    },
//    "timestamp": 1707374804916,
//    "recipient": "all"
//}
