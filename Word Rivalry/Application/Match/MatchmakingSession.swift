//
//  MatchmakingDelegate.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation
import SwiftUI
import OSLog

enum MatchmakingSessionError: Error {
    case adversaryNotFound
    case failedToConnect
    case failedToJoinQueue
}

@Observable final class MatchmakingSession {
    
    var local: User
    var adversary: User?
    var adversaryEloRating: Int?
    var gameID: String?
    var error: Error?
    
    private let matchmakingSocket: MatchmakingSocketService
   
    init(
        local: User,
        matchmakingSocket: MatchmakingSocketService = MatchmakingSocketService()
    ) {
        self.local = local
        self.matchmakingSocket = matchmakingSocket
        self.matchmakingSocket.setMatchmakingDelegate(self)
    }
    
    // MARK: Join Queue
    private let joinQueue = JoinQueue()
    
    func joinQueue(by amount: Int) async throws -> Void {
        
        let request = JoinQueueRequest(
            user: self.local,
            matchmakingSocket: self.matchmakingSocket
        )
        
        try await self.joinQueue.execute(request: request)
    }
    
    // MARK: Leave Queue
    private let leaveQueue = LeaveQueue()
    
    func leaveQueue() async throws -> Void {
        try await self.leaveQueue.execute(request: self.matchmakingSocket)
    }
}

// MARK: MatcMatchmakingDelegate
extension MatchmakingSession: MatchmakingDelegate {
    func didJoinedQueue() {
        Task { @MainActor in
            withAnimation(.easeInOut) {
                error = nil
            }
        }
    }
    
    func didNotJoinedQueue() {
        Task { @MainActor in
            withAnimation(.easeInOut) {
                self.error = MatchmakingSessionError.failedToConnect
            }
        }
    }
    
    func didNotConnect() {
        Task { @MainActor in
            withAnimation(.easeInOut) {
                self.error = MatchmakingSessionError.failedToConnect
            }
        }
    }
    
    func didFoundMatch(gameSessionUUID: String, opponentUsername: String, opponentElo: Int) {
        let fetchUser = UserFetch()
        self.gameID = gameSessionUUID
        self.adversaryEloRating = opponentElo
        
        Task {
            do {
                self.adversary = try await fetchUser.execute(request: opponentUsername)
            } catch {
                
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        self.error = MatchmakingSessionError.adversaryNotFound
                    }
                }
                return
            }
            
            Logger.match.debug("opponentProfile fetched")
        }
    }
}
