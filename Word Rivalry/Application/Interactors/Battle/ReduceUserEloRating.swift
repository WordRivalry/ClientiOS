//
//  EloRatingUpdate.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

/// Manages the reduction of a user's Elo rating in a public database.
final class ReduceUserEloRating: UseCaseProtocol {
    /// `Request` represents the amount by which the Elo rating should be decreased.
    typealias Request = Int
    
    /// `Response` represents the `User` object that reflects the updated Elo rating.
    typealias Response = User
    
    /// Reference to the shared database instance used for accessing and updating user data.
    private let database = PublicDatabase.shared.db
    
    /// Reduces a specific user's Elo rating in the database.
    /// - Parameter request: The amount by which the Elo rating should be decreased.
    /// - Returns: The updated `User` object with the decreased Elo rating.
    /// - Throws: Propagates errors from the database layer related to fetching or updating data.
    func execute(request: Request) async throws -> Response {
        let userRecordID = try await database.userRecordID()
        let user: User = try await database.queryModelUserReference(by: userRecordID)
        
        // Calculate reduced elo rating
        let reducedEloRating = user.eloRating - request
        
        // Update the user's Elo rating field with the new reduced value.
        return try await database.update(for: user, field: .eloRating, with: reducedEloRating)
    }
}

