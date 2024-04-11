//
//  DataSource.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-31.
//

import Foundation
import SwiftData
import os.log

final class SwiftDataSource {
    var isReady: Bool = false
    
    private var modelContainer: ModelContainer
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "SwiftData", category: "DataSource")

    @MainActor
    static let shared = SwiftDataSource()

    @MainActor
    init() {
        self.logger.info("*** Datasource STARTED ***")
     
        self.logger.info("Datasource for DEV")
        self.modelContainer = try! ModelContainer(
            for: Profile.self, AchievementProgression.self, Friend.self,
            configurations: ModelConfiguration(cloudKitDatabase: .private("iCloud.WordRivalryContainer"))
        )
        self.modelContext = modelContainer.mainContext
        
        self.isReady = true
        self.logger.info("*** DataSource START COMPLETED ***")
    }
    
    func save() {
        Task { @MainActor in
            do {
                try modelContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
            logger.debug("Ctx saved")
        }
    }

    func appendProfile(_ profile: Profile) {
        Task { @MainActor in
            modelContext.insert(profile)
            do {
                try modelContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
            
            logger.debug("Ctx Profile inserted and saved")
        }
    }

    func fetchProfiles() -> [Profile] {
        do {
            let ret = try modelContext.fetch(FetchDescriptor<Profile>())
            logger.debug("Ctx Profile fetched ")
            return ret;
        } catch {
            fatalError(error.localizedDescription)
        }
     
    }

    func removeProfile(_ profile: Profile) {
        Task { @MainActor in
            modelContext.delete(profile)
            logger.debug("Ctx Profile deleted ")
        }
    }
    
    // MARK: - Achiement progression
    
    func appendAchievementProgression(_ achievementProgression: AchievementProgression) {
        Task { @MainActor in
            modelContext.insert(achievementProgression)
            do {
                try modelContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
            logger.debug("Ctx AchievementProgression inserted and saved")
        }
    }
    
    func fetchAchievementProgression() -> [AchievementProgression] {
        do {
            let ret = try modelContext.fetch(FetchDescriptor<AchievementProgression>())
            logger.debug("Ctx AchievementProgression fetched ")
            return ret;
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func removeAchievementProgression(_ achievementProgression: AchievementProgression) {
        Task { @MainActor in
            modelContext.delete(achievementProgression)
            logger.debug("Ctx AchievementProgression deleted ")
        }
    }
    
    // MARK: - Friends
    
    func appendFriend(_ friend: Friend) {
        Task { @MainActor in
            modelContext.insert(friend)
            do {
                try modelContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
            logger.debug("Ctx friend inserted and saved")
        }
    }
    
    func fetchFriends() -> [Friend] {
        do {
            let ret = try modelContext.fetch(FetchDescriptor<Friend>())
            logger.debug("Ctx AchievementProgression fetched ")
            return ret;
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func removeFriend(_ friend: Friend) {
        Task { @MainActor in
            modelContext.delete(friend)
            logger.debug("Ctx friend deleted ")
        }
    }
}
