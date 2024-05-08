//
//  UserFetch.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

/// Fetches user data from a public database and uses local storage as a fallback.
final class FetchSomeUser {
    
    static let userRepository: UserRepository = UserRepository()

    /// Fetches the user's data primarily from the database, with fallback to local storage on failure.
    /// - Returns: The `User` object corresponding to the current user's record.
    /// - Throws: Propagates errors if both the database and local storage fetching fail.
    static func execute(with username: String) async throws -> User {
        return try await userRepository.fetchAnyUser(by: username)
    }
}


