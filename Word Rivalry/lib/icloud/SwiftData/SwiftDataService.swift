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
    var profile: Profile?
    var friends: [Friend] = []

    init() {
        self.logger.info("*** DataService STARTED ***")
        Task { @MainActor in
            self.dataSource = SwiftDataSource.shared
        }
    }
    
    func fetchProfile() async {
        // Wait until the DataSource is ready
        while !(await SwiftDataSource.shared.isReady) {
            try? await Task.sleep(nanoseconds: 100_000_000)
            Logger.dataServices.info("Awaiting DataSource... 100ms")
        }
        
        guard let dataSource = self.dataSource else {  logger.error("\(self.NO_DATA_SOURCE)"); return }
        let profiles = dataSource.fetchProfiles()
        
        if profiles.count >= 1 {
            logger.error("\(profiles.count) Profiles found!")
            self.profile = profiles[0]
        } else {
            logger.info("Profile not found")
            self.profile = nil
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
    
    private let NO_DATA_SOURCE: String = "No datasource available!"
}

// MARK: AppService conformance

extension SwiftDataService: AppService {
    var isReady: Bool {
        profile != nil
    }
    
    var isCritical: Bool {
        true
    }
    
    func start() async -> String {
        guard let dataSource = self.dataSource else { return "\(self.NO_DATA_SOURCE)" }
        
        let profiles = dataSource.fetchProfiles()
        
        if profiles.count >= 1 {
            logger.debug("\(profiles.count) Profile found")
            self.profile = profiles[0]
        } else {
            logger.debug("Profile not found")
            self.profile = nil
        }
        
        //  self.friends = dataSource.fetchFriends()
        //  logger.debug("[\(self.friends.count)] Friends found")
        
        self.logger.info("*** DataService START COMPLETED ***")
        
        return "Profile is loaded? [\(self.profile != nil)]"
    }
    
    func handleAppBecomingActive() {}
    
    func handleAppGoingInactive() {}
    
    func handleAppInBackground() {}
}
