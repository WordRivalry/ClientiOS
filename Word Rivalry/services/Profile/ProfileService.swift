//
//  ProfileInfoService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import CloudKit

//@Observable class ProfileService: ObservableObject {
//    static let shared = ProfileService()
//    
//    private let cloudKitService: CloudKitService
//    private var cachedUsername: String?
//    private var cachedEloRating: Int?
//    private var cachedUUID: String?
//    
//    private init() {
//        self.cloudKitService = CloudKitService()
//    }
//    
//    func loadProfile() async throws {
//        do {
//            self.cachedUsername = try await self.fetchUsername()
//            self.cachedUUID = try await self.fetchUUID()
//            self.cachedEloRating = try await self.fetchEloRating()
//            
//            // Save
//            PlayerDefaultsManager.shared.setUsername(self.getUsername())
//            PlayerDefaultsManager.shared.setUserUUID(self.getUUID())
//            print("Profile loaded via Cloud")
//        } catch { // Fails if first time oppening app on device
//           
//            // Load from default
//            self.cachedUsername = try PlayerDefaultsManager.shared.getUsername()
//            self.cachedUUID = try PlayerDefaultsManager.shared.getUserUUID()
//            self.cachedEloRating = try PlayerDefaultsManager.shared.getUserEloRating()
//            print("Player Profile loaded via defaults")
//       
//        }
//    }
//    
//    func getUsername() -> String {
//        guard let cachedUsername = self.cachedUsername else { return "" }
//        return cachedUsername
//    }
//    
//    func getUUID() -> String {
//        guard let cachedUUID = self.cachedUUID else { return "" }
//        return cachedUUID
//    }
//    
//    // MARK: PRIVATE PROFILE
//    
//    // Creates a new user profile
//    func createProfile(username: String) async throws {
//        try await self.cloudKitService.createUserRecord(playerName: username)
//        try await self.loadProfile()
//    }
//    
//    // Function to get the username for the current iCloud user
//    func fetchUsername() async throws -> String {
//        if let username = self.cachedUsername {
//            // If self.username has a value, unwrap it safely and return it
//            return username
//        }
//        // If self.username is nil, try to fetch the username asynchronously
//        let username = try await self.cloudKitService.fetchPlayerName()
//        self.cachedUsername = username // Cache the username for future calls
//        return username
//    }
//    
//    // Function to get the UUID for the current iCloud user
//    func fetchUUID() async throws -> String {
//        if let uuid = self.cachedUUID {
//            // Return cache value if available
//            return uuid
//        } else {
//            // Fetch value and cache it
//            let uuid = try await self.cloudKitService.fetchUUID()
//            self.cachedUUID = uuid
//            return uuid
//        }
//    }
//    
//    func fetchEloRating() async throws -> Int {
//        if let eloRating = self.cachedEloRating {
//            // Return cache value if available
//        } else {
//            // Fetch value and cache it
//            let eloRating = try await self.cloudKitService.fetchUUID()
//            self.cachedEloRating = eloRating
//            return eloRating
//        }
//    }
//
//    // Updates the username for a given user record
//    func updateUsername(to newPlayerName: String) async throws -> Void {
//        // Attempt to update the username record in CloudKit
//        try await self.cloudKitService.updatePlayerNameRecord(playerName: newPlayerName)
//        // Upon successful update, cache the new username
//        self.cachedUsername = newPlayerName
//    }
//    
//    // Check if a profile already exists for the user
//    func exist() async throws -> Bool {
//        return !(try await self.cloudKitService.isUserNew())
//    }
//    
//    
//    // MARK: FRIEND
//    
//    func addFriend(username: String) async throws -> Void {
//        return try await self.cloudKitService.addFriend(byUsername: username)
//    }
//    
//    func deleteFriend(friendUUID: String) async throws -> Void {
//        return try await self.cloudKitService.removeFriend(friendUUID: friendUUID)
//    }
//    
//    func searchByUsername(username: String) async throws -> CKRecord? {
//        return try await self.cloudKitService.searchPublicUser(byPlayerName: username)
//    }
//}
