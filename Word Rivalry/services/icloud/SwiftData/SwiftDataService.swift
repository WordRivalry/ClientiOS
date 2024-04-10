//
//  DataService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-02.
//

import Foundation
import os.log

@Observable
class SwiftDataService {
    @ObservationIgnored
    private var dataSource: SwiftDataSource?
    @ObservationIgnored
    private let logger = Logger(subsystem: "SwiftData", category: "DataService")
    @ObservationIgnored
    var isReady: Bool = false
    
    var profile: Profile?
    var achievementProgressions: [AchievementProgression] = []
    var friends: [Friend] = []

    init() {
        self.logger.info("*** DataService STARTED ***")
        Task { @MainActor in
            self.dataSource = SwiftDataSource.shared
            guard let dataSource = self.dataSource else { logger.error("\(self.NO_DATA_SOURCE)"); return }
            
            let profiles = dataSource.fetchProfiles()
            
            if profiles.count >= 1 {
                logger.debug("\(profiles.count) Profile found")
                self.profile = profiles[0]
            } else {
                logger.debug("Profile not found")
                self.profile = nil
            }
            
            self.achievementProgressions = dataSource.fetchAchievementProgression()
            logger.debug("[\(self.achievementProgressions.count)] Achievement Progressions found")
            
            
            self.friends = dataSource.fetchFriends()
            logger.debug("[\(self.friends.count)] Friends found")
            
            self.isReady = true
            self.logger.info("*** DataService START COMPLETED ***")
        }
    }
    
    func createProfile(profile: Profile) {
        guard let dataSource = self.dataSource else { logger.error("\(self.NO_DATA_SOURCE)"); return }
        if (self.profile != nil) { logger.debug("Profile already in DataService"); return }
        dataSource.appendProfile(profile)
        self.profile = profile
    }
    
    func save() {
        guard let dataSource = self.dataSource else { logger.error("\(self.NO_DATA_SOURCE)"); return }
        dataSource.save()
    }

    func deleteProfile(_ index: Int) {
        guard let dataSource = self.dataSource else { logger.error("\(self.NO_DATA_SOURCE)"); return }
        if let profile = profile {
            dataSource.removeProfile(profile)
        }
    }
    
    func createProgression(progression: AchievementProgression) {
        guard let dataSource = self.dataSource else { logger.error("\(self.NO_DATA_SOURCE)"); return }
        dataSource.appendAchievementProgression(progression)
    }
    
    private let NO_DATA_SOURCE: String = "No datasource available!"
}
