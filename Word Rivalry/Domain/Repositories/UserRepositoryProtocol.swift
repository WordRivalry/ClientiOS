//
//  UserRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

protocol UserRepositoryProtocol {
    
    /// Fetches the user's data primarily from the database, with fallback to local storage on failure.
    /// - Returns: The `User` object corresponding to the current user's record.
    /// - Throws: Propagates errors if both the database and local storage fetching fail.
    func fetchUser() async throws -> User
    
    
    func fetchUser(by username: String) async throws -> User
    func isUserNew() async throws -> Bool
    func saveUser(_: User) async throws -> User
    
    /// Checks if a username is unique within the database.
    /// - Parameter username: The username to check.
    /// - Returns: `false` if the  username already exists; otherwise, `true`.
    /// - Throws: An error if the database query fails.
    func isUsernameUnique(_ playerName: String) async throws -> Bool
}
