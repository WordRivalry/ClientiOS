//
//  UserFetch.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

/// Fetches user data from a public database and uses local storage as a fallback.
final class FetchSomeUser: UseCaseProtocol {
    /// `Request` does not carry any data as this use case only fetches the current user's data.
    typealias Request = String
    
    /// `Response` represents the type of data that this use case returns upon completion.
    /// In this case, it is a `User` object retrieved from the database or local storage.
    typealias Response = User
    
    let userRepository: UserRepository = UserRepository()

    /// Fetches the user's data primarily from the database, with fallback to local storage on failure.
    /// - Returns: The `User` object corresponding to the current user's record.
    /// - Throws: Propagates errors if both the database and local storage fetching fail.
    func execute(request: Request) async throws -> User {
        return try await userRepository.fetchUser(by: request)
    }
}


