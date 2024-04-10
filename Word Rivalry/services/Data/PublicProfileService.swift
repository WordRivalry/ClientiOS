//
//  PublicProfileService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

@Observable final class PublicProfileService {
    var player: PublicProfile?
    
    func subscribeToChanges() async throws {
        try await PublicDatabase.shared.subscribeToChanges()
    }
    
    static var shared: PublicProfileService = PublicProfileService()
    private init() {}
    
    func fetchData() async {
        do {
            self.player = try await fetchPlayer()
            Logger.dataServices.info("PublicProfile updated")
        } catch {
            Logger.dataServices.error("Failed to fetch top players: \(error.localizedDescription)")
        }
    }
    
    private func fetchPlayer() async throws -> PublicProfile? {
        //try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        return try await PublicDatabase.shared.fetchOwnPublicProfileIfExist()
    }
    
    static var preview: PublicProfileService {
        let service = PublicProfileService()
        service.player = PublicProfile.preview
        return service
    }
}
