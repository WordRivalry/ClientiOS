//
//  PublicProfileService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

@Observable final class PPLocalService {
    var player: PublicProfile?
    
    func subscribeToChanges() async throws {
        try await PublicDatabase.shared.subscribeToChanges()
    }
    
    static var shared: PPLocalService = PPLocalService()
    private init() {}
    
    func fetchData() async {
        do {
            if let player = try await fetchPlayer() {
                self.player = player
            }
            Logger.dataServices.info("Local public profile updated")
        } catch {
            Logger.dataServices.error("Failed to fetch local public profile: \(error.localizedDescription)")
        }
    }
    
    private func fetchPlayer() async throws -> PublicProfile? {
        return try await PublicDatabase.shared.fetchOwnPublicProfileIfExist()
    }
    
    static var preview: PPLocalService {
        let service = PPLocalService()
        service.player = PublicProfile.preview
        return service
    }
}
