//
//  SocketIOService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation
import SocketIO
import OSLog

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the SocketIOService events from the app
    static let socketIOService = Logger(subsystem: subsystem, category: "SocketIOService")
}

protocol EventProtocol: RawRepresentable where RawValue == String {
    var eventString: String { get }
}

extension EventProtocol {
    var eventString: String {
        return rawValue
    }
}

class SocketIOService<Event: EventProtocol> {
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    init(url: URL) {
        self.manager = SocketManager(socketURL: url, config: [
            .log(true),
            .compress,
            .reconnects(true),
            .reconnectAttempts(5),
            .reconnectWait(1)
        ])
        self.socket = manager?.defaultSocket
    }
    
    func status() -> SocketIOStatus? {
        return self.socket?.status
    }
    
    func connect(payload: [String : Any]? = nil) {
        // Set up base connection and error handling
        socket?.on(clientEvent: .connect) { data, ack in
            Logger.socketIOService.debug("Socket connected")
        }
        
        socket?.on("error") { data, ack in
            if let error = data[0] as? String {
                Logger.socketIOService.error("Socket connection error: \(error)")
            }
        }
        
        // This will automatically manage reconnections as configured above
        socket?.connect(withPayload: payload)
    }
    
    func send(event: Event) {
        socket?.emit(event.eventString)
    }
    
    func send(event: Event, text: String) {
        socket?.emit(event.eventString, text)
    }
    
    func send<T: Codable>(event: Event, codableObject: T) {
        do {
            let jsonData = try JSONEncoder().encode(codableObject)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                Logger.socketIOService.error("Failed to convert JSON data to String.")
                return
            }
            send(event: event, text: jsonString)
        } catch {
            Logger.socketIOService.error("Error encoding codable object: \(error.localizedDescription)")
        }
    }
    
    func onEvent(
        _ event: Event,
        callback: @escaping ([Any], SocketAckEmitter) -> Void
    ) {
        socket?.on(event.eventString, callback: callback)
    }
    
    func onEvent<T: Codable>(
        _ event: Event,
        decodeAs type: T.Type,
        eventHandler handler: @escaping (T, SocketAckEmitter) -> Void
    ) {
        socket?.on(event.eventString) { [weak self] data, ack in
            guard let self = self, let decodedData: T = self.decodeMessage(from: data) else { return }
            handler(decodedData, ack)
        }
    }
    
    private func decodeMessage<T: Codable>(from data: [Any]) -> T? {
        guard let text = data[0] as? String,
              let jsonData = text.data(using: .utf8) else {
            Logger.socketIOService.error("Failed to convert received data to text")
            return nil
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch {
            Logger.socketIOService.error("Failed to decode JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func disconnect() {
        socket?.disconnect()
        Logger.socketIOService.debug("Socket disconnected")
    }
}
