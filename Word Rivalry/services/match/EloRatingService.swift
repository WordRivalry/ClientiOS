//
//  EloRatingService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-06.
//

import Foundation
import os.log

enum EloRatingState: String {
    case unchanged
    case hasPendingAmount
    case pending
    case complete
    case cancelled
}

@Observable class EloRatingService {
    var pendingAmount: Int = 0
    var defaultEloRating: Int
    var state: EloRatingState = .unchanged
    let profile: PublicProfile
    private let logger = Logger(subsystem: "com.WordRivalry", category: "EloRatingService")
    
    init(for profile: PublicProfile) {
        self.profile = profile
        self.defaultEloRating = profile.eloRating
        self.logger.info("*** EloRatingService STARTED ***")
    }
    
    func setPendingAmount(amount: Int) {
        self.pendingAmount = amount
        self.state = .hasPendingAmount
    }
    
    func attributePoint() {
        guard state == .pending else {
            fatalError("Not in \(EloRatingState.pending) State")
        }
        Task { @MainActor in
            let pending = self.pendingAmount * 2
            self.profile.eloRating += pending
            _ = try await PublicDatabase.shared.updatePlayerEloRating(saving: self.profile.eloRating)
            self.state = .complete
            self.logger.info("\(self.pendingAmount) elo point has been attributed")
        }
    }
    
    func cancel() {
        guard state == .pending else {
            fatalError("Not in \(EloRatingState.pending) State")
        }
        Task { @MainActor in
            self.profile.eloRating += self.pendingAmount
            self.logger.info("Elo transaction has been cancelled")
            self.state = .cancelled
        }
    }
    
    func deductPoint() {
        guard state == .hasPendingAmount else {
            fatalError("Not in \(EloRatingState.hasPendingAmount) State")
        }
        
        Task { @MainActor in
            self.profile.eloRating -= self.pendingAmount
            _ = try await PublicDatabase.shared.updatePlayerEloRating(saving: self.profile.eloRating)
            self.logger.info("\(self.pendingAmount) elo point has been deducted")
            self.state = .pending
        }
    }
    
    deinit {
        if self.state == .pending {
            self.logger.info("Deinit during \(self.state.rawValue) state")
            self.cancel()
        }
    }
}

