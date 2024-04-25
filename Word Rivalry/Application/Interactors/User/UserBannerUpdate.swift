//
//  UserBannerUpdate.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation


/// Manages the update process for a user's banner in a public database.
final class UserBannerUpdate: UseCaseProtocol {
    /// `Request` represents the type of data that this use case expects to receive to perform its operation.
    /// In this case, it is a `Banner` representing the new banner to be set for the user.
    typealias Request = Banner
    
    /// `Response` represents the type of data that this use case returns upon completion.
    /// In this case, it is a `User` object that reflects the updated banner.
    typealias Response = User
    
    let userRepository: UserRepository = UserRepository()
    
    /// Updates a specific user's banner in the database.
    /// - Parameter request: The new banner to be set for the user.
    /// - Returns: The updated `User` object reflecting the new banner.
    /// - Throws: Propagates errors from the database layer related to fetching or updating data.
    func execute(request: Request) async throws -> Response {
        let user: User = try await userRepository.fetchUser()
        user.banner = request.rawValue
        return try await userRepository.saveUser(user)
    }
}
