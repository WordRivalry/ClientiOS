//
//  WebSocketManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-21.
//

import Foundation

class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession: URLSession
    
    init(url: URL) {
        self.urlSession = URLSession(configuration: .default)
        self.webSocketTask = urlSession.webSocketTask(with: url)
    }
    
    func connect() {
        webSocketTask?.resume()
        listenForMessages()
    }
    
    func send(text: String) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket sending error: \(error)")
            }
        }
    }
    
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text message: \(text)")
                case .data(let data):
                    print("Received binary data: \(data)")
                default:
                    break
                }
                
                // Continue listening for the next message
                self?.listenForMessages()
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}

