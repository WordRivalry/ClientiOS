//
//  UserRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation
import OSLog
import GameKit

final class UserRepository: UserRepositoryProtocol {
    
    
    /// Reference to the shared database instance used for accessing user data.
    private let database: CloudKitManageable
    
    /// Local file storage for backing up or retrieving the user data when the database is unavailable.
    let userStorage: FileStorage<User> = FileStorage<User>(fileName: "user.data")
    
    init(db: CloudKitManageable = PublicDatabase.shared.db) {
        database = db
    }
        
    func fetchAnyUser(by userID: String) async throws -> User {
        return try await database.queryModel(by: .userID, value: userID)
    }
    
    func fetchLocalUser() async throws -> User {
        let userRecordName = try await database.userRecordID().recordName
        
        do {
            let user = try await fetchAnyUser(by: userRecordName)
            await cacheUser(user)
            return user
        } catch ModelError.modelNotFound { // New
            let user = User.init(userID: userRecordName)
            let savedUser = try await database.saveModel(saving: user)
            await cacheUser(savedUser)
            return savedUser
        } catch {
            // If database fetch fails, attempt to retrieve the user from local file storage.
            if let cachedUser = try? await userStorage.load() {
                return cachedUser // Return cached user if available.
            } else {
                throw error
            }
        }
    }
    
    func saveUser(_ user: User) async throws -> User {
        let updatedUser = try await database.saveModel(saving: user)
        await cacheUser(updatedUser)
        return updatedUser
    }
    
    private func cacheUser(_ user: User) async {
         do {
             Logger.cloudKit.info("Caching user.")
             try await userStorage.save(data: user)
         } catch {
             Logger.cloudKit.error("Failed to cache user: \(error.localizedDescription).")
         }
     }
}
