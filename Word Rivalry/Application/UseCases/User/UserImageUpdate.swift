//
//  UserImageUpdate.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

/// Manages the update process for a user's profile image in a public database.
final class UserImageUpdate: UseCaseProtocol {
    /// `Request` represents the type of data that this use case expects to receive to perform its operation.
    /// In this case, it is a `ProfileImage` representing the new image to be set for the user.
    typealias Request = ProfileImage
    
    /// `Response` represents the type of data that this use case returns upon completion.
    /// In this case, it is a `User` object that reflects the updated profile image.
    typealias Response = User
    
    let userRepository: UserRepository = UserRepository()
    
    /// Updates a specific user's profile image in the database.
    /// - Parameter request: The new profile image to be set for the user.
    /// - Returns: The updated `User` object reflecting the new profile image.
    /// - Throws: Propagates errors from the database layer related to fetching or updating data.
    func execute(request: Request) async throws -> Response {
        let user: User = try await userRepository.fetchUser()
        user.profileImage = request.rawValue
        return try await userRepository.saveUser(user)
    }
}
