//
//  AppDataService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog



@Observable class AppDataService: SceneLifeCycle {
    var leaderboardService: LeaderboardService
   // var publicProfileService: PublicProfileService
    
    @ObservationIgnored
    var dataServicesHooked: [SceneLifeCycle] = []
    
    init(leaderboardService: LeaderboardService = LeaderboardService()) {
        self.leaderboardService = leaderboardService
     //   self.publicProfileService = PublicProfileService()
        dataServicesHooked.append(self.leaderboardService)
     //   dataServicesHooked.append(self.publicProfileService)
    }

    func handleAppBecomingActive() {
        self.dataServicesHooked.forEach { dataService in
            dataService.handleAppBecomingActive()
        }
    }
    
    func handleAppGoingInactive() {
        self.dataServicesHooked.forEach { dataService in
            dataService.handleAppGoingInactive()
        }
    }
    
    func handleAppInBackground() {
        self.dataServicesHooked.forEach { dataService in
            dataService.handleAppInBackground()
        }
    }
    
    static var preview: AppDataService {
        AppDataService(leaderboardService: .preview)
    }
}
