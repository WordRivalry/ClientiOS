//
//  ProfileDataService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import OSLog

@Observable
class ProfileDataService: ServiceCoordinator {
    var swiftData: SYPData<Profile>?
    let ppLocal: PPLocalService
    
    override init() {
        
        self.ppLocal = PPLocalService.sharedInstace
        super.init()
        
        Task { @MainActor in
            self.swiftData = SYPData<Profile>()
        }
        
        self.startPriority = .critical(1)
        self.identifier = "ProfileDataService"
       // self.addService(swiftData)
        self.addService(ppLocal)
    }
    
    override func precondition() async -> Bool {
        do {
            try await findOrCreateProfile()
            await ppLocal.fetchData()
            return true
        } catch {
            Logger.dataServices.info("ProfileDataService - Error: \(error)")
            return false
        }
    }
    
    private func findOrCreateProfile() async throws {
        let profile = try await self.findProfile()
        if profile == nil {
            // We need to check online
            await ppLocal.fetchData()
            if !self.ppLocal.isHealthy {
                // We need to create the accounts
                try await self.createProfiles()
            }
        }
    }
    
    private func findProfile() async throws -> Profile? {
        Logger.dataServices.info("Finding profile...")
        
        while swiftData == nil {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        
        while !swiftData!.isReady {
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
        
        if let profile = self.swiftData?.fetchItems().first {
            Logger.dataServices.info("Profile found!")
            return profile
        } else {
            Logger.dataServices.info("Profile not found!")
            return nil
        }
    }
    
    private func createProfiles() async throws {
        Logger.dataServices.info("Creating profiles...")
        
        guard NetworkChecker.shared.isConnected else {
            Logger.dataServices.debug("No Connection to internet found...")
            return
        }
        Logger.dataServices.info("Connection to internet verified")
        
        // Check for recovery, else create all
        
        if let publicProfile = try await PublicDatabase.shared.fetchOwnPublicProfileIfExist() {
            // Public profile
            ppLocal.player = publicProfile
            Logger.dataServices.debug("Public profile exist")
            // SwiftData profile
            self.createProfile()
        } else {
            Logger.dataServices.debug("Public profile does not exist")
            try await createBothProfileAndPublicProfile()
        }
    }
    
    private func createBothProfileAndPublicProfile() async throws {
      
        // Public profile
        ppLocal.player = try await PublicDatabase.shared.addPublicProfileRecord(playerName: String(UUID().uuidString.prefix(10)))
        Logger.dataServices.debug("Public profile created")
        
        // SwiftData profile
        self.createProfile()
    }
    
    private func createProfile() -> Void {
        // SwiftData profile
        let profile = Profile.new
        self.swiftData?.appendItem(profile)
        Logger.dataServices.debug("Swiftdata profile created")
    }
}
