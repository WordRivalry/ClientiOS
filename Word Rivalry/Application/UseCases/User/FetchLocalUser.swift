//
//  PublicProfileCreate.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation
import CloudKit

/// `FetchLocalUser` is a use case class responsible for fetching an existing `User` or initializing a new user profile.
/// This use case ensures the user either retrieves an existing profile or receives a unique,
/// newly initialized profile if no previous data exists.
final class FetchLocalUser: UseCaseProtocol {
    
    /// `Request` does not carry any data as this use case only fetches the current user's data.
    typealias Request = Void
    
    /// `Response` represents the type of data that this use case returns upon completion.
    /// In this case, it is a `User` object retrieved from the database or local storage.
    typealias Response = User

    /// Repository managing user data operations.
    let userRepository: UserRepository = UserRepository()
    
    /// Fetches the user's data primarily from the database, with fallback to local storage on failure.
    /// - Returns: The `User` object corresponding to the current user's record.
    /// - Throws: Propagates errors if both the database and local storage fetching fail.
    func execute(request: Request = ()) async throws -> Response {
        let user: User = try await userRepository.fetchUser()
        
        // Check if the user is new and initialize their profile with a unique player name.
        if isNewUser(for: user) {
            let playerName = try await generateUniqueName()
            user.playerName = playerName
            return try await userRepository.saveUser(user)
        }
        
        // Return the existing user if not new.
        return user
    }
    
    /// Generates a unique player name that does not exist in the database.
    /// Utilizes a loop to repeatedly generate names until a unique one is confirmed.
    /// - Returns: A `String` representing a unique player name.
    private func generateUniqueName() async throws -> String {
        var username = generateRandomName()
        while try await notUnique(username) {
            username = generateRandomName()
        }
        return username
    }
    
    /// Creates a random player name using the first 10 characters of a UUID, providing a simple method for generating potential unique identifiers.
    /// - Returns: A `String` consisting of the first 10 characters of a UUID.
    private func generateRandomName() -> String {
        String(UUID().uuidString.prefix(10))
    }
    
    /// Checks if a player name already exists in the database, ensuring player names are unique.
    /// - Parameter username: The username to check.
    /// - Returns: `true` if the username already exists; otherwise, `false`.
    /// - Throws: An error if the database query fails.
    private func notUnique(_ username: String) async throws -> Bool {
        return try await !userRepository.isUsernameUnique(username)
    }
    
    /// Checks if the user profile is essentially empty, used to determine if the user is new and requires initialization.
    /// - Parameter user: The `User` object to check.
    /// - Returns: `true` if the user's player name field is empty, indicating a new, uninitialized user.
    private func isNewUser(for user: User) -> Bool {
        return user.playerName.isEmpty
    }
}
