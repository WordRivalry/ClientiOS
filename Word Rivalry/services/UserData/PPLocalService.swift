//
//  PublicProfileService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

@Observable final class PPLocalService {
    
    /// Public profile of the user
    /// Is static sense we do not need multiple intances of the profile
    var player: PublicProfile?
    static var sharedInstace: PPLocalService = PPLocalService()
    
    private init() {
        Task {
            try? await self.subscribeToChanges()
        }
    }
    
    func subscribeToChanges() async throws {
        try await PublicDatabase.shared.subscribeToChanges()
    }
    
    func fetchData() async {
        do {
            if let player = try await fetchPlayer() {
                self.player = player
            } else {
                Logger.dataServices.info("Local public profile not found")
            }
        } catch {
            Logger.dataServices.error("Failed to fetch local public profile: \(error.localizedDescription)")
        }
    }
    
    private func fetchPlayer() async throws -> PublicProfile? {
        return try await PublicDatabase.shared.fetchOwnPublicProfileIfExist()
    }
    
    private func findOrCreateProfile() async throws {
        Logger.dataServices.info("Creating profiles...")
        
        guard NetworkChecker.shared.isConnected else {
            Logger.dataServices.debug("No Connection to internet found...")
            return
        }
        Logger.dataServices.info("Connection to internet verified")
        
        // Check for recovery, else create all
        
        if let publicProfile = try await fetchPlayer() {
            self.player = publicProfile
            Logger.dataServices.debug("Public profile exist")
        } else {
            Logger.dataServices.debug("Public profile does not exist")
            try await createProfile()
        }
    }
    
    private func createProfile() async throws {
      
        guard NetworkChecker.shared.isConnected else {
            Logger.dataServices.debug("No Connection to internet found...")
            return
        }
        
        // Public profile
        self.player = try await PublicDatabase.shared.addPublicProfileRecord(playerName: String(UUID().uuidString.prefix(10)))
        Logger.dataServices.debug("Public profile created")
    }

    // MARK: Preview
    
    static var preview: PPLocalService {
        let service = PPLocalService()
        service.player = PublicProfile.preview
        return service
    }
}

// MARK: AppService conformance
extension PPLocalService: AppService {

    var isHealthy: Bool {
        get { self.player != nil }
        set {}
    }

    var identifier: String { "PPLocalService" }
    
    var startPriority: ServiceStartPriority {
        .critical(1)
    }
    
    func start() async -> String {
        try? await self.findOrCreateProfile()
        return "Public profile loaded? [\(self.player != nil)]"
    }
    
    func handleAppBecomingActive() {
        if !self.isHealthy {
            Task {
                await self.fetchData()
            }
        }
    }
    func handleAppGoingInactive() {}
    func handleAppInBackground() {}
}
