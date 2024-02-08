//
//  WebSocketService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-05.
//

import Foundation

protocol WebSocket_MatchmakingDelegate: AnyObject {
    func didReceiveOpponentUsername(opponentUsername: String)
    func didReceivePreGameCountDown(countdown: Int)
}

protocol WebSocket_GameDelegate: AnyObject {
    func didReceiveRoundStart(roundNumber: Int, duration: Int, grid: [[LetterTile]])
    func didUpdateTime(_ remainingTime: Int)
    func didEndRound(round: Int, playerScore: Int, opponentScore: Int, winner: String)
    func didUpdateOpponentScore(_ score: Int)
    func didReceiveGameEnd(winners: [String], winnerStatus: String)
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

class WebSocketService: NSObject {
    var webSocketTask: URLSessionWebSocketTask?
    var profileService: ProfileService?
    var gameDelegate: WebSocket_GameDelegate?
    var matchmakingDelegate: WebSocket_MatchmakingDelegate?
    
    override init() {
        super.init()
        self.profileService = ProfileService()
        connect()
    }

    func connect() {
        guard let url = URL(string: "ws://battleserver-dtyigx66oa-nn.a.run.app") else { return }
        var request = URLRequest(url: url)
        request.addValue("your_valid_api_key", forHTTPHeaderField: "x-api-key")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        listen()
    }
    
    func setGameDelegate(_ delegate :WebSocket_GameDelegate) {
        self.gameDelegate = delegate
    }
    
    func setMatchmakingDelegate(_ delegate :WebSocket_MatchmakingDelegate) {
        self.matchmakingDelegate = delegate
    }
    
    func initiateHandshake() async {
        do {
            // Use guard let to unwrap the optional values safely.
            guard let username = try await profileService?.getUsername() else {
                print("Username is nil")
                return // Exit early if username is nil
            }
            
            guard let uuid = try await profileService?.getUUID() else {
                print("UUID is nil")
                return // Exit early if uuid is nil
            }

            let handshakeMessage = composeHandshakeMessage(uuid: uuid, username: username, reconnecting: false)
            send(message: handshakeMessage)
        } catch {
            print("Error fetching profile data for handshake: \(error)")
        }
    }

    private func composeHandshakeMessage(uuid: String, username: String, reconnecting: Bool) -> String {
          let handshakeDict: [String: Any] = [
              "type": "handshake",
              "uuid": uuid,
              "username": username,
              "reconnecting": reconnecting
          ]
          
          if let jsonData = try? JSONSerialization.data(withJSONObject: handshakeDict, options: []),
             let jsonString = String(data: jsonData, encoding: .utf8) {
              return jsonString
          } else {
              print("Error composing handshake message")
              return ""
          }
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
        case "roundStart":
            handleRoundStartMessage(json)
        case "timeUpdate":
            handleTimeUpdate(json)
        case "endRound":
            handleEndRound(json)
        case "opponentScoreUpdate":
            handleOpponentScoreUpdate(json)
        case "gameStartCountdown":
            handlePreGameCountdown(json)
        case "gameEnd":
            print("Game ended: \(json)")
        case "metaData":
            handleMetaData(json)
            
        case "gameStart":
                if let startTime = json["startTime"] as? Int64,
                   let duration = json["duration"] as? Int,
                   let gridArray = json["grid"] as? [[[String: Any]]] {
                    let grid = gridArray.map { row -> [LetterTile] in
                        row.compactMap { LetterTile.from($0) }
                    }
                    matchmakingDelegate?.didReceiveGameReadyToStart(startTime: startTime, duration: duration, grid: grid)
                }
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

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket did open")
        Task {
            await initiateHandshake()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket did close")
    }
}

extension WebSocketService {
    // Send a message to start the matchmaking process
    func findMatch() {
        let message = composeMessage(type: "findMatch")
        send(message: message)
    }
    
    // Send a message to stop the matchmaking process
    func stopFindMatch() {
        let message = composeMessage(type: "stopFindMatch")
        send(message: message)
    }
    
    // Acknowledge that the game can start
    func ackStartGame() {
        let message = composeMessage(type: "ackStartGame")
        send(message: message)
    }
    
    
//    {
//        "id": "8ac3ed14-bab2-40d5-9567-a3aa1f5a4a6f",
//        "type": "opponentUsernames",
//        "payload": [
//            "Payer1"
//        ],
//        "timestamp": 1707374801910,
//        "recipient": "121212-121212-121212"
//    }
    // Handle receiving the opponent's metadata
    private func handleMetaData(_ json: [String: Any]) {
        print("Received metaData: \(json)")
        // Check if the "type" of the message is "opponentUsernames"
        if let type = json["type"] as? String, type == "opponentUsernames" {
            // Attempt to extract the "payload" as an array of Strings
            if let payload = json["payload"] as? [String], !payload.isEmpty {
                // Assuming you're interested in the first username
                let opponentUsername = payload[0]
                matchmakingDelegate?.didReceiveOpponentUsername(opponentUsername: opponentUsername)
            }
        }
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
    
    // Helper method to compose a generic message
    private func composeMessage(type: String) -> String {
        let dict: [String: Any] = ["type": type]
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            print("Error composing \(type) message")
            return ""
        }
    }
    
    func sendScoreUpdate(wordPath: [[Int]]) {
         let messageDict: [String: Any] = [
             "type": "scoreUpdate",
             "wordPath": wordPath,
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
