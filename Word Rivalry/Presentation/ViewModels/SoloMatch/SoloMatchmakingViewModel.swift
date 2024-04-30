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



@Observable final class SoloMatchmakingViewModel {
    
   
    var error: Error?
    
    private let matchmakingSocket: MatchmakingSocketService
   
    init(
        matchmakingSocket: MatchmakingSocketService = MatchmakingSocketService()
    ) {
        self.matchmakingSocket = matchmakingSocket
        self.matchmakingSocket.setSearchDelegate(self)
    }
    
    // MARK: Join Queue
    private let joinQueueInteractor = JoinQueue()
    
    func joinQueue() async throws -> Void {
        
        let request = JoinQueueRequest(
            network: self.matchmakingSocket,
            stake: 10
        )
        
        try await self.joinQueueInteractor.execute(request: request)
    }
    
    // MARK: Leave Queue
    private let leaveQueueInteractor = LeaveQueue()
    
    func leaveQueue() throws -> Void {
        try self.leaveQueueInteractor.execute(request: self.matchmakingSocket)
    }
}

// MARK: MatcMatchmakingDelegate
extension SoloMatchmakingViewModel: MatchmakingSocketService_Search_Delegate {
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
}
