//
//  LaunchService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-06.
//

import Foundation
import os.log

enum LaunchScreen {
    case intro
    case noIcloud
    case noInternet
    case home
    case error
}

@Observable class LaunchService: Service {
 
    private let logger = Logger(subsystem: "com.WordRivalry", category: "LaunchService")
    
    var screenToPresent: LaunchScreen = .intro
    
    var leaderboard: LeaderboardService?
    var profile: Profile?
    var achievementsProgression: AchievementsProgression?
    var friends: Friends?
    
    let dataService: SwiftDataService
    var isReady: Bool = false
    
    init(dataService: SwiftDataService) {
        self.dataService = dataService
        self.logger.info("*** LaunchService STARTED ***")
        Task {
           await prepareLaunchData()
        }
    }
    
    /// Starts the launch preparation process.
    func prepareLaunchData() async {
        guard iCloudService.shared.iCloudStatus == .available else {
             logger.info("*** LaunchService ENDED due to no iCloud ***")
             screenToPresent = .noIcloud
             return
         }
        
        await waitForDataService()
        
        do {
            try await handleUserData()
        } catch {
            self.logger.error("\(error.localizedDescription)" )
            screenToPresent = .error
        }
        
        self.logger.info("*** LaunchService COMPLETED ***")
        self.screenToPresent = .home
        self.isReady = true // END
            
    }
    
    private func waitForDataService() async {
          while !dataService.isReady {
              try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
              logger.info("Awaiting dataService... 100ms")
          }
      }
    
    private func handleUserData() async throws {
          try await findOrCreateProfile()
          try await ensurePublicProfileExists()
          checkIfMissingProgression()
          
          await fetchFriendList()
          await fetchLeaderboard()
      }
    
    private func findOrCreateProfile() async throws {
        if let profile = try await self.findProfile() {
            self.useProfile(profile)
        } else { // New Player
            try await self.createProfiles()
        }
    }
    
    private func ensurePublicProfileExists() async throws {
        await PublicProfileService.shared.fetchData()
    }
    
    private func findProfile() async throws -> Profile? {
        self.logger.info("Finding profile...")
        
        if let profile = self.dataService.profile {
            self.logger.info("Profile found!")
            return profile
        } else {
            self.logger.info("Profile not found!")
            return nil
        }
    }
    
    private func createProfiles() async throws {
        self.logger.info("Creating profiles...")
        
        guard NetworkChecker.shared.isConnected else {
            self.logger.debug("No Connection to internet found...")
            screenToPresent = .noInternet
            return
        }
        self.logger.info("Connection to internet verified")
        
        // Check for recovery, else create all
        
        if let publicProfile = try await PublicDatabase.shared.fetchOwnPublicProfileIfExist() {
            // Public profile
            PublicProfileService.shared.player = publicProfile
            self.logger.debug("Public profile exist")
            
            // SwiftData profile
            self.createProfile()
        } else {
            self.logger.debug("Public profile does not exist")
            try await createBothProfileAndPublicProfile()
        }
    }
    
    private func createBothProfileAndPublicProfile() async throws {
      
        // Public profile
        PublicProfileService.shared.player = try await PublicDatabase.shared.addPublicProfileRecord(playerName: UUID().uuidString)
        self.logger.debug("Public profile created")
        
        // SwiftData profile
        self.createProfile()
    }
    
    private func createProfile() -> Void {
        // SwiftData profile
        let profile = Profile.new
        dataService.createProfile(profile: profile)
        self.logger.debug("Swiftdata profile created")
        self.useProfile(profile)
    }
    
    private func useProfile(_ profile: Profile) {
        self.profile = profile
        self.logger.info("Profile is READY!")
    }
    
    private func checkIfMissingProgression() {
        let existingAchievements = Set(self.dataService.achievementProgressions.map { $0.name })
        let allAchievements = Set(AchievementName.allCases.map { $0.rawValue })
        
        // Find the difference between all achievements and what currently exists.
        let missingAchievements = allAchievements.subtracting(existingAchievements)
        
        // For each missing achievement, create a new progression and append it.
        for achievementName in missingAchievements {
            // This adaptation is necessary since you're pre-fetching data now.
            let progression = AchievementsManager.shared.newProgression(for: AchievementName(rawValue: achievementName)!)
            self.dataService.createProgression(progression: progression)
        }
        
        // Call save once after all new progressions have been appended
        self.dataService.save()
        
        self.achievementsProgression = AchievementsProgression(
            progressions: self.dataService.achievementProgressions
        )
        
        self.logger.info("Achievements are READY!")
    }
    
    private func fetchFriendList() async {
        self.friends = Friends(friends: self.dataService.friends)
        self.logger.info("The friend list is READY!")
    }
    
    private func fetchLeaderboard() async {
//        self.leaderboard = .init()
//        while !(leaderboard!.isReady) {
//            try? await Task.sleep(nanoseconds: 100_000_000)
//            self.logger.info("Awaiting leaderboard service... 100ms")
//        }
//        self.leaderboard?.startPeriodicUpdate()
//        self.logger.info("Leaderboard is READY!")
    }
    
    private func fetchPublicProfile2() async throws {
        
//        if let publicProfile = try await PublicDatabase.shared.fetchOwnPublicProfileIfExist() {
//            // Public profile
//            self.publicProfile = publicProfile
//            self.logger.debug("Public profile exist")
//        }
    }
}
