//
//  AchievementsService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import Foundation
import GameKit
import OSLog

@Observable final class AchievementsService: DataService {
    var gkAchievements: [GKAchievement] = []
      
    init() {
        super.init(fetchEvery: 10)
    }
    
    @MainActor
    override func fetchData() async {
        do {
            self.gkAchievements = try await GKAchievement.loadAchievements()
            Logger.dataServices.info("GKAchievements updated")
        } catch {
            Logger.dataServices.error("Failed to fetch GKAchievements: \(error.localizedDescription)")
        }
    }
    
    override func isDataAvailable() -> Bool {
        if gkAchievements.isEmpty {
            return false
        }
        return true
    }
    
    static var preview: AchievementsService {
        let service = AchievementsService()
        service.gkAchievements = [
            GKAchievement(identifier: "newleaf"),
            GKAchievement(identifier: "wordconqueror"),
            GKAchievement(identifier: "wordsmith"),
            GKAchievement(identifier: "centurion"),
            GKAchievement(identifier: "wordking")
        ]
        return service
    }
}
