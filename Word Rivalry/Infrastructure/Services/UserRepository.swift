//
//  UserRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation

enum UserRepositoryError: Error {
    case notAbleToGatherUserData(Error)
}

final class UserRepository: UserRepositoryProtocol {
    
    func isUserNew() async throws -> Bool {
        return try await database.isUserNew()
    }
    
    func fetchUser(by username: String) async throws -> User {
        return try await database.queryModel(by: .playerName, value: username)
    }
    
    /// Fetches the user's data primarily from the database, with fallback to local storage on failure.
    /// - Returns: The `User` object corresponding to the current user's record.
    /// - Throws: Propagates errors if both the database and local storage fetching fail.
    func fetchUser() async throws -> User {
        // Retrieve user record name from cache, or fetch from the database if not available in cache.
        let userRecordName = try await fetchUserRecordName()
        do {
            // Attempt to fetch the user from the database.
            let user: User = try await database.queryModelUserReference(by: userRecordName)
            // If fetch is successful, update local file storage with the fresh data.
            await cacheUser(user)
            return user
        } catch {
            // If database fetch fails, attempt to retrieve the user from local file storage.
            if let cachedUser = try? await userStorage.load() {
                return cachedUser // Return cached user if available.
            } else {
                // If no user data is available in local storage, rethrow the original database error.
                throw error
            }
        }
    }
    
    func saveUser(_ user: User) async throws -> User {
        let updatedUser = try await database.saveModel(saving: user)
        await cacheUser(updatedUser)
        return updatedUser
    }
    
    /// Checks if a player name is unique within the database.
    /// - Parameter playerName: The player name to check.
    /// - Returns: `false` if the player name already exists; otherwise, `true`.
    /// - Throws: An error if the database query fails.
    func isUsernameUnique(_ playerName: String) async throws -> Bool {
        return try await database.isUnique(type: User.self, by: .playerName, value: playerName)
    }
    
    /// Reference to the shared database instance used for accessing user data.
    let database = PublicDatabase.shared.db
    
    /// Local cache for storing user record names to avoid repeated database fetches.
    var userDefaults: UserDefaultsCache<String> = UserDefaultsCache<String>()
    
    /// Local file storage for backing up or retrieving the user data when the database is unavailable.
    var userStorage: FileStorage<User> = FileStorage<User>(fileName: "user.data")
    
    /// The key used to store the user record name in UserDefaults.
    let userRecordKey = "userRecordName"
    
    /// Retrieves the user record name from a local cache or queries it from the database if not present in the cache.
    ///
    /// This method first checks if the user record name is stored in the local `UserDefaults`. If it is found,
    /// it returns this value. If not, the method queries the database to obtain the user's record ID, extracts
    /// the record name from this ID, caches it for future reference, and then returns the record name. This
    /// approach reduces the need for repeated database queries, thereby enhancing performance and reducing
    /// network usage.
    ///
    /// - Returns: A `String` representing the user's record name.
    /// - Throws: `CKError.Code.notAuthenticated` : If a failure to resolve icloud account readiness or icloud drive access.
    ///   Other errors that might arise from the `database.userRecordID()`.
    ///
    /// ## Example
    ///
    /// Here is how you might use the `fetchUserRecordName` method:
    ///
    /// ```swift
    /// do {
    ///     let recordName = try await fetchUserRecordName()
    ///     print("User record name: \(recordName)")
    /// } catch {
    ///     print("Error fetching user record name: \(error)")
    /// }
    /// ```
    ///
    /// - Note: This method assumes that the user record ID fetched from the database will always include a
    ///   valid `recordName`. If the `recordName` is missing or invalid, the method might propagate an unexpected
    ///   error. Additionally, any failures during the caching process are not explicitly handled here, which
    ///   could affect subsequent operations if the cache is not properly updated.
    private func fetchUserRecordName() async throws -> String {
        if let userRecordName = userDefaults.get(forKey: userRecordKey) {
            return userRecordName
        } else {
            let recordID = try await database.userRecordID()
            let userRecordName = recordID.recordName
            userDefaults.set(userRecordName, forKey: userRecordKey) // Cache the record name.
            return userRecordName
        }
    }

    
    
    /// Saves a `User` object to local file storage.
    ///
    /// This method attempts to persist a `User` object to the local file system by encoding it as JSON and writing the data to a file specified by the `FileStorage<User>` instance. If the save operation fails due to an error (e.g., disk space issues, permission problems), the method will attempt to invalidate the cache, which might involve deleting corrupted data or resetting the state to ensure the consistency of future operations.
    ///
    /// - Parameter user: The `User` object to be saved. This object should be fully populated and valid.
    /// - Throws: `FileStorageError.saveFailed`: If the underlying file system operations fail.
    ///   Other errors thrown by `JSONEncoder` or `FileManager` depending on the issue encountered during the save operation.
    ///
    /// ## Example
    ///
    /// Here is how you might use the `saveUser` method:
    ///
    /// ```swift
    ///     let user = User(...)
    ///     await saveUser(user)
    /// ```
    ///
    /// - Note: If the save operation fails, the method silently attempts to invalidate the cache without rethrowing any errors from the invalidation process. This design choice helps in mitigating potential data corruption but might mask underlying issues with the cache system.
    private func cacheUser(_ user: User) async -> Void {
        do {
            try await self.userStorage.save(data: user)
        } catch {
            // If saving fails, invalidate the cache
            try? self.userStorage.invalidate()
        }
    }
}
