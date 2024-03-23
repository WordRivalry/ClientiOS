//
//  ProfileInfoService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import CloudKit

@Observable class ProfileService: ObservableObject {
    static let shared = ProfileService()
    
    private let cloudKitService: CloudKitService
    private var cachedUsername: String?
    private var cachedUUID: String?
    
    private init() {
        self.cloudKitService = CloudKitService()
    }
    
    func loadProfile() async throws {
        do {
            // Load from default
            self.cachedUsername = try UserDefaultsManager.shared.getUsername()
            self.cachedUUID = try UserDefaultsManager.shared.getUserUUID()
            print("Profile loaded via defaults")
        } catch { // Fails if first time oppening app on device
            self.cachedUsername = try await self.fetchUsername()
            self.cachedUUID = try await self.fetchUUID()
            
            // Save
            UserDefaultsManager.shared.setUsername(self.getUsername())
            UserDefaultsManager.shared.setUserUUID(self.getUUID())
            print("Profile loaded via Cloud")
        }
    }
    
    func getUsername() -> String {
        guard let cachedUsername = self.cachedUsername else { return "" }
        return cachedUsername
    }
    
    func getUUID() -> String {
        guard let cachedUUID = self.cachedUUID else { return "" }
        return cachedUUID
    }
    
    // MARK: PRIVATE PROFILE
    
    // Creates a new user profile
    func createProfile(username: String) async throws {
        try await self.cloudKitService.createUserRecord(username: username)
        try await self.loadProfile()
    }
    
    // Function to get the username for the current iCloud user
    func fetchUsername() async throws -> String {
        if let username = self.cachedUsername {
            // If self.username has a value, unwrap it safely and return it
            return username
        }
        // If self.username is nil, try to fetch the username asynchronously
        let username = try await self.cloudKitService.fetchUsername()
        self.cachedUsername = username // Cache the username for future calls
        return username
    }
    
    // Function to get the UUID for the current iCloud user
    func fetchUUID() async throws -> String {
        if let uuid = self.cachedUUID {
            // Return cached UUID if available
            return uuid
        } else {
            // Fetch and cache the UUID if not already cached
            let uuid = try await self.cloudKitService.fetchUUID()
            self.cachedUUID = uuid
            return uuid
        }
    }

    // Updates the username for a given user record
    func updateUsername(to newUsername: String) async throws -> Void {
        // Attempt to update the username record in CloudKit
        try await self.cloudKitService.updateUsernameRecord(username: newUsername)
        // Upon successful update, cache the new username
        self.cachedUsername = newUsername
    }
    
    // Check if a profile already exists for the user
    func exist() async throws -> Bool {
        return !(try await self.cloudKitService.isUserNew())
    }
    
    
    // MARK: FRIEND
    
    func addFriend(username: String) async throws -> Void {
        return try await self.cloudKitService.addFriend(byUsername: username)
    }
    
    func deleteFriend(friendUUID: String) async throws -> Void {
        return try await self.cloudKitService.removeFriend(friendUUID: friendUUID)
    }
    
    func searchByUsername(username: String) async throws -> CKRecord? {
        return try await self.cloudKitService.searchPublicUser(byUsername: username)
    }
}
