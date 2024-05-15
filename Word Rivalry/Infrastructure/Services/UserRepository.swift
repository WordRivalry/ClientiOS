//
//  UserRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation
import OSLog
import GameKit
import CryptoKit

struct UserDetail: Decodable {
    let country: String
    let soloWin: Int
    let displayName: String
    let subscriptionEndDate: Double  // Using Double for TIMESTAMP
    let primaryColor: String
    let teamMatch: Int
    let teamWin: Int
    let avatar: String
    let allTimeStars: Int
    let currentStars: Int
    let experience: Int
    let title: String
    let accent: String
    let userID: String
    let soloMatch: Int
    let defaultAvatar: String
    let isSubscribed: Int
    let defaultColor: String
    let profileEffect: String
    let avatarFrame: String
    let achievementsPoints: Int
}

final class UserRepository: UserRepositoryProtocol {
    
    
    /// Reference to the shared database instance used for accessing user data.
    private let database: CloudKitManageable
    
    private let api = APIService.shared
    
    /// Local file storage for backing up or retrieving the user data when the database is unavailable.
    let userStorage: FileStorage<User> = FileStorage<User>(fileName: "user.data")
        
    init(db: CloudKitManageable = PublicDatabase.shared.db) {
        Logger.cloudKit.fault("UserRepository init")
        database = db
    }
        
    func fetchAnyUser(by userID: String) async throws -> User {
        return try await database.queryModel(by: .userID, value: userID)
    }
    
    func fetchManyUser(by userIDs: [String]) async throws -> [User] {
        return try await database.queryModels(by: .userID, values: userIDs)
    }
    
    func stableInt64Hash(from input: String) -> Int64 {
        // Convert the input string to UTF-8 encoded data
        let inputData = Data(input.utf8)
        
        // Hash the data using SHA-256
        let hash = SHA256.hash(data: inputData)
        
        // Convert the first 8 bytes of the hash to UInt64, then to Int64
        var result: UInt64 = 0
        let bytes = Array(hash.prefix(8)) // Take only the first 8 bytes
        for byte in bytes {
            result = result << 8
            result |= UInt64(byte)
        }
        
        return Int64(bitPattern: result)
    }

    func fetchLocalUser() async throws -> UserDetail {
        let recordName  = try await database.userRecordID().recordName
        
        let userID = recordName
        
        do {
            
            let result = await api.requestData(
                url: "http://localhost:8080/api/v1/users/byid",
                method: .GET,
                expecting: UserDetail.self
            )
            
            switch result {
            case .success(let userDetails):
                
            case .failure(let hTTPError):
                <#code#>
            }
            
            let user = try await fetchAnyUser(by: "\(userID)")
            
            await cacheUser(user)
            return user
        } catch ModelError.modelNotFound { // New
            let user = User.init(userID: "\(userID)")
            let savedUser = try await database.saveModel(saving: user)
            await cacheUser(savedUser)
            return savedUser
        } catch {
            
            Logger.cloudKit.fault("Failed to fetch or create user.")
            
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
