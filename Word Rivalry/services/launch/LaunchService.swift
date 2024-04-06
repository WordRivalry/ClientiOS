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

@Observable class LaunchService {
    
    private let logger = Logger(subsystem: "com.WordRivalry", category: "LaunchService")
    
    var screenToPresent: LaunchScreen = .intro
    
    var leaderboard: LeaderboardService?
    var profile: Profile?
    var achievementsProgression: AchievementsProgression?
    var friends: Friends?
    
    let dataService: DataService
    
    init(dataService: DataService) {
        self.dataService = dataService
        self.logger.info("*** LaunchService STARTED ***")
        prepareLaunchData()
    }
    
    /// Starts the launch preparation process.
    func prepareLaunchData() {
        if iCloudService.shared.iCloudStatus == .available {
            Task {
                while !(dataService.isReady) {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    self.logger.info("Awaiting dataService... 100ms")
                }
                await findProfile()
                checkIfMissingProgression()
                
                self.friends = Friends(friends: self.dataService.friends)
                self.logger.info("Friends READY!")
                
                self.leaderboard = .init()
                while !(leaderboard!.isReady) {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    self.logger.info("Awaiting leaderboard service... 100ms")
                }
                self.leaderboard?.startPeriodicUpdate()

                self.logger.info("*** LaunchService COMPLETED ***")
                self.screenToPresent = .home
            }
        } else {
            screenToPresent = .noIcloud // END
            self.logger.info("*** LaunchService ENDED due to no iCloud ***")
        }
    }
    
    private func findProfile() async {
        self.logger.info("Starting find profile...")
        
        if let profile = self.dataService.profile {
            useProfile(profile)
            return
        }
        
        guard NetworkChecker.shared.isConnected else {
            self.logger.debug("No Connection to internet found...")
            screenToPresent = .noInternet
            return
        }
        
        self.logger.info("Connection to internet verified")
        do {
            self.logger.info("Recovering public profile...")
            
            if let profile = try await PublicDatabase.shared.fetchProfileIfExist() {
                self.logger.debug("Public profile exist")
                dataService.createProfile(profile: profile)
                self.logger.debug("Profile added to SwiftData")
                useProfile(profile)
                
            } else {
                self.logger.debug("Public profile does not exist")
                let profile = try await createProfile()
                useProfile(profile)
            }
        } catch {
            self.logger.debug("Verification with internet failed")
            screenToPresent = .error
        }
    }
    
    private func createProfile() async throws -> Profile {
        self.logger.info("Creating new profile...")
        
        // Public profile
        let profile = try await PublicDatabase.shared.addProfileRecord(playerName: UUID().uuidString)
        self.logger.debug("Public profile created")
        
        // SwiftData profile
        dataService.createProfile(profile: profile)
        self.logger.debug("Swiftdata profile created")
        return profile
    }
    
    private func useProfile(_ profile: Profile) {
        self.profile = profile
        self.logger.info("Profile READY!")
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
        
        self.logger.info("Achievements Progressions READY!")
    }
    
    private func findTopPlayers() async {
       
    }
}
