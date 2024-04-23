//
//  WebSocketService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-21.
//

import Foundation
import os.log

class WebSocketService: NSObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var url: URL?
    private var headers: [String: String] = [:]
    private var reconnectionAttempts = 0
    private let maxReconnectionAttempts = 5
    private var messageQueue: [String] = []
    private var isConnected = false
    private var shouldReconnect = true
    
    // MARK: - WebSocket Connection
    func connect(url: URL, headers: [String: String]) {
        self.shouldReconnect = true
        self.url = url
        self.headers = headers
        self.reconnectionAttempts = 0
        self.attemptConnection()
    }
    
    private func attemptConnection() {
        guard let url = url else { return }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        var request = URLRequest(url: url)
        self.headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        self.webSocketTask = session.webSocketTask(with: request)
        self.webSocketTask?.resume()
        self.listenForMessages()
        self.isConnected = true
        
        self.log("Attempting connection to \(url.absoluteString)...", category: "Reconnection attempt", type: .info)
        
        // Schedule a ping to monitor connection health
        self.schedulePing()
    }
    
    // MARK: - Send Message
    func send(text: String) {
        guard isConnected else {
            self.messageQueue.append(text)
            return
        }
        
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                // Instead of directly logging the error, use handleError to process and log it.
                self.handleError(error, context: "sendMessage")
                
                // Update the connection status and queue the message for resend.
                self.isConnected = false
                self.messageQueue.append(text)
                
                // Attempt to reconnect based on the error handling logic.
                self.reconnect()
            }
        }
    }
    
    func send<T: Codable>(_ codableObject: T) {
        do {
            let jsonData = try JSONEncoder().encode(codableObject)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                // If this fails, it's considered a critical unrecoverable error.
                // Log the error before terminating.
                self.handleError(NSError(domain: "WebSocketService",
                                         code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON data to String."]),
                                 context: "sendMessageCodable")
                return
            }
            self.send(text: jsonString)
        } catch {
            self.handleError(error, context: "sendMessageCodable")
        }
    }
    
    // MARK: - Reconnection Logic
    private func reconnect() {
        guard self.shouldReconnect else { return }
        guard reconnectionAttempts < maxReconnectionAttempts else {
            self.log("Max reconnection attempts reached. Giving up.", category: LogCategory.connection, type: .error)
            disconnect()
            return
        }
        
        let backoffTime = pow(2.0, Double(reconnectionAttempts))
        DispatchQueue.global().asyncAfter(deadline: .now() + backoffTime) { [weak self] in
            guard let self = self else { return }
            self.reconnectionAttempts += 1
            self.log("Attempting reconnection (Attempt \(self.reconnectionAttempts))...", category: LogCategory.connection, type: .info)
            self.attemptConnection()
        }
    }
    
    // MARK: - Connection Monitoring
    private func schedulePing() {
        webSocketTask?.sendPing { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(error, context: "ping")
                self.isConnected = false
                self.reconnect()
            } else {
                self.log("WebSocket ping successful.", category: LogCategory.connection, type: .info)
                DispatchQueue.global().asyncAfter(deadline: .now() + 25) {
                    self.schedulePing()
                }
            }
        }
    }
    
    // MARK: - Receive Messages
    private func listenForMessages() {
        guard let webSocketTask = webSocketTask else {
            self.log("Connection is closed or disconnecting, stopping message listening.", category: LogCategory.connection, type: .info)
            return
        }
        
        webSocketTask.receive { [weak self] result in
            switch result {
            case .failure(let error):
                self?.handleError(error, context: "receiveMessage")
                if (self?.shouldReconnect != nil) && !((self?.isConnected) != nil) {
                    self?.reconnect() // Ensure reconnect is only called under appropriate conditions.
                }
            case .success(let message):
                if ((self?.isConnected) != nil) {
                    self?.handleMessage(message)
                }
            }
            
            // Continue listening for messages
            self?.listenForMessages()
        }
    }
    
    // MARK: - Handle Received Message
    func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            handleTextMessage(text)
        case .data(let data):
            handleDataMessage(data)
        @unknown default:
            fatalError("Unknown message type received")
        }
    }
    
    // MARK: - Abstract Methods to be Overridden by Subclasses
    func handleTextMessage(_ text: String) {
        // Intended to be overridden by subclasses
        fatalError("handleTextMessage(_:) has not been implemented")
    }
    
    func handleDataMessage(_ data: Data) {
        // Intended to be overridden by subclasses
        fatalError("handleDataMessage(_:) has not been implemented")
    }
    
    // MARK: - Disconnect
    func disconnect() {
        self.shouldReconnect = false // Prevent any further reconnection attempts
        self.isConnected = false
        self.webSocketTask?.cancel(with: .goingAway, reason: nil)
        self.webSocketTask = nil
        self.messageQueue.removeAll()
        self.log("Disconnect initiated. Halting all activities.", category: LogCategory.connection, type: .info)
    }
}

// MARK: - URLSessionWebSocketDelegate
extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.isConnected = true
        self.log("WebSocket did open", category: LogCategory.connection, type: .info)
        self.sendQueuedMessages()
    }
    
    private func sendQueuedMessages() {
        while !self.messageQueue.isEmpty {
            self.send(text: messageQueue.removeFirst())
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        shouldReconnect = false // Prevent reconnection attempts after a server-initiated close
        
        // Handle specific close codes
        switch closeCode {
        case .goingAway:
            log("Server initiated disconnect with 'Going Away'. No reconnection attempt will be made.", category: LogCategory.connection, type: .info)
            
            // Additional cleanup or reset logic can be placed here if needed
            teardownConnection()
        case .noStatusReceived, .abnormalClosure:
            // These could indicate network issues or unexpected drops.
            
            handleError(URLError(URLError.networkConnectionLost))
        default:
            log("Connection closed with code \(closeCode). No reconnection attempt will be made.", category: LogCategory.connection, type: .info)
            
            // Additional cleanup or reset logic can be placed here if needed
            teardownConnection()
        }
    }
    
    private func teardownConnection() {
        webSocketTask = nil // Ensure the webSocketTask is cleared to release resources
        messageQueue.removeAll() // Optionally clear the message queue or handle unsent messages
    }
}

// MARK: - Log
extension WebSocketService {
    
    // Log categories for better diagnostics
    private enum LogCategory {
        static let connection = "WebSocketConnection"
        static let messaging = "WebSocketMessaging"
        static let networkError = "NetworkError"
        static let clientMessageError = "ClientMessageError"
        static let serverMessageError = "ServerMessageError"
    }
    
    // Enhanced logging using Unified Logging System
    private func log(_ message: String, category: String, type: OSLogType = .default) {
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: category)
        os_log("%{public}@", log: log, type: type, message)
    }
    
    private func handleError(_ error: Error, context: String = "") {
        if let urlError = error as? URLError {
            handleURLError(urlError)
            return
        }
        
        // Cast the error to a more specific NSError to check its domain and code
        let nsError = error as NSError
        
        // Check for the specific "Socket is not connected" error
        if nsError.domain == NSPOSIXErrorDomain && nsError.code == 57 {
            // Log this specific error or handle it accordingly
            log("Socket is not connected. Dump.", category: LogCategory.networkError, type: .info)
            reconnect()
            return // Early return to avoid executing further error handling logic
        } else {
            // Non-URL errors are handled based on the context
            handleContextSpecificError(error, context: context)
        }
    }
    
    private func handleURLError(_ error: URLError) {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut:
            log("Network issue: \(error.localizedDescription). Attempting to reconnect.", category: LogCategory.networkError, type: .info)
            reconnect()
        default:
            log("URL error: \(error.localizedDescription)", category: LogCategory.networkError, type: .error)
        }
    }
    
    private enum ContextSpecificError {
        static let receiveMessage = "ReceiveMessage"
        static let sendMessageCodable = "SendMessage"
    }
    
    private func handleContextSpecificError(_ error: Error, context: String) {
        switch context {
        case "sendMessage":
            log("Error sending message: \(error.localizedDescription)", category: LogCategory.clientMessageError, type: .error)
            // Consider retrying or informing the user, based on error type.
        case "receiveMessage":
            log("Server-side message error: \(error.localizedDescription)", category: LogCategory.serverMessageError, type: .error)
            // Retry listening for messages or escalate the issue.
        case "sendMessageCodable":
            log("Failed to process Codable data: \(error.localizedDescription)", category: LogCategory.clientMessageError, type: .error)
            // Avoid fatalError in production. Consider a retry mechanism or error callback instead.
        case "":
            fatalError("Context missing for context based error handling.")
        default:
            log("Unexpected error: \(error.localizedDescription)", category: LogCategory.connection, type: .error)
        }
    }
}

