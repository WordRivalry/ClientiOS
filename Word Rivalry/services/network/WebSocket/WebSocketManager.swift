//
//  WebSocketManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-21.
//

import Foundation
import os.log

class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "com.WordRivalry", category: "WebSocketManager")
    
    init(url: URL) {
        self.urlSession = URLSession(configuration: .default)
        self.webSocketTask = urlSession.webSocketTask(with: url)
    }
    
    func connect() {
        webSocketTask?.resume()
        listenForMessages()
        self.logger.debug("Connection...")
    }
    
    func send(text: String) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { error in
            if let error = error {
                self.logger.error("WebSocket sending error: \(error)")
            }
        }
    }
    
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                self?.logger.error("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.logger.debug("Received text message: \(text)")
                case .data(let data):
                    self?.logger.debug("Received binary data: \(data)")
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
        self.logger.debug("Disconnection...")
    }
}

