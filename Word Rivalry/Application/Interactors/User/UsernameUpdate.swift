//
//  UsernameUpdate.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation
import CloudKit

/// Manages the update process for a user's username in a public database. Ensures the username is unique
/// before updating.
final class UsernameUpdate: UseCaseProtocol {
    /// `Request` represents the type of data that this use case expects to receive to perform its operation.
    /// In this case, it is a `String` representing the new username to be set for the user.
    typealias Request = String
    
    /// `Response` represents the type of data that this use case returns upon completion.
    /// In this case, it is a `User` object that reflects the updated username.
    typealias Response = User
    
    let userRepository: UserRepository = UserRepository()
    
    /// Updates a specific user's username in the database.
    /// - Parameter request: The new username to be set for the user.
    /// - Returns: The updated `User` object reflecting the new username.
    /// - Throws: `UserUCError.usernameTaken` if the requested username is already taken.
    ///           Propagates other errors from the database layer related to fetching or updating data.
    func execute(request: Request) async throws -> Response {
        if !(try await userRepository.isUsernameUnique(request)) {
            throw UserUCError.usernameTaken
        }
        
        let user: User = try await userRepository.fetchUser()
        user.playerName = request
        return try await userRepository.saveUser(user)
    }
}
