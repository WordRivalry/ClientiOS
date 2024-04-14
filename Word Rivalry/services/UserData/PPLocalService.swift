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
        await self.fetchData()
        return "Public profile loaded? [\(self.player != nil)]"
    }
    
    func handleAppBecomingActive() {Task {await self.fetchData()}}
    func handleAppGoingInactive() {}
    func handleAppInBackground() {}
}
