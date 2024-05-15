//
//  UserRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

enum UserRepositoryError: Error {
    case dataNotFound(String)       // Specific data not found.
    case dataUnavailable            // General failure to access data.
    case unauthorizedAccess         // Lack of permissions or authorization.
    case saveFailure(String)        // Detailed failure to save data.
    case retrievalFailure(String)   // Detailed failure to retrieve data.
    case unknown(String)            // An unknown error with detail.
}

protocol UserRepositoryProtocol {
    
    /// Fetches the user's data primarily from the database, with fallback to local storage on failure.
    /// - Returns: The `User` object corresponding to the current user's record.
    /// - Throws: Propagates errors if both the database and local storage fetching fail.
    func fetchLocalUser() async throws -> User
    func fetchAnyUser(by userID: String) async throws -> User
    func fetchManyUser(by userIDs: [String]) async throws -> [User]
    func saveUser(_: User) async throws -> User
}
