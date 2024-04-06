//
//  RewardManagaer.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import Foundation
import os.log

// MARK: - CONTENT DEFINITION
enum ContentAccessibility: Equatable {
    case base
    case unlockable(source: ContentSource)
    
    enum ContentAccessibilityError: Error {
        case BaseHasNotProgression
    }
    
    func isUnlocked(using progressions: AchievementsProgression) -> Bool {
        switch self {
        case .base:
             true
        case .unlockable(source: let source):
            switch source {
            case .achievement(let achievementName):
                progressions.isUnlocked(for: achievementName)
            }
        }
    }
    
    func progression(using progressions: AchievementsProgression) -> AchievementProgression? {
        switch self {
        case .base:
            nil
        case .unlockable(source: let source):
            switch source {
            case .achievement(let achievementName):
                progressions.getProgression(for: achievementName)
            }
        }
    }
    
    func achievementName() -> AchievementName? {
        switch self {
        case .base:
            nil
        case .unlockable(source: let source):
            switch source {
            case .achievement(let achievementName):
                achievementName
            }
        }
    }
}

enum ContentSource: Equatable {
    case achievement(AchievementName)  // Tied to an achievement
}

protocol ContentItem {
    var id: String { get }
    var description: String { get }
    var requirement: String? { get }
    var accessibility: ContentAccessibility { get }
}

struct TitleItem: ContentItem {
    var id: String { display }
    var display: String
    var description: String
    var requirement: String?
    var accessibility: ContentAccessibility
}

struct ProfileImageItem: ContentItem {
    var id: String { assetName }
    var assetName: String
    var description: String
    var requirement: String?
    var accessibility: ContentAccessibility
}

struct BannerItem: ContentItem {
    var id: String { assetName }
    var assetName: String
    var description: String
    var requirement: String?
    var accessibility: ContentAccessibility
}

// MARK: - REPOSITORY
class ContentRepository {
    static let shared = ContentRepository()
    var banners: ContentStore<BannerItem>
    var titles: ContentStore<TitleItem>
    var profileImages: ContentStore<ProfileImageItem>
    private let logger = Logger(subsystem: "com.WordRivalry", category: "ContentRepository")
    
    init() {
        // Initialize stores
        banners = ContentStore<BannerItem>()
        titles = ContentStore<TitleItem>()
        profileImages = ContentStore<ProfileImageItem>()
        loadContentItems()
        self.logger.debug("Initiated and loaded")
    }
    
    func getAchievement(for title: Title) -> AchievementName? {
        forKey(title).accessibility.achievementName()
    }
    func getAchievement(for banner: Banner) -> AchievementName? {
        forKey(banner).accessibility.achievementName()
    }
    func getAchievement(for profileImage: ProfileImage) -> AchievementName? {
        forKey(profileImage).accessibility.achievementName()
    }
    
    func getDescription(for title: Title) -> String {
        forKey(title).description
    }
    func getDescription(for banner: Banner) -> String {
        forKey(banner).description
    }
    func getDescription(for profileImage: ProfileImage) -> String {
        forKey(profileImage).description
    }
    func isUnlocked(using progressions: AchievementsProgression, _ title: Title) -> Bool {
        forKey(title).accessibility.isUnlocked(using: progressions)
    }
    func isUnlocked(using progressions: AchievementsProgression, _ banner: Banner) -> Bool {
        forKey(banner).accessibility.isUnlocked(using: progressions)
    }
    func isUnlocked(using progressions: AchievementsProgression, _ profileImage: ProfileImage) -> Bool {
        forKey(profileImage).accessibility.isUnlocked(using: progressions)
    }
    func getProgression(using progressions: AchievementsProgression, _ title: Title) -> AchievementProgression? {
        forKey(title).accessibility.progression(using: progressions)
    }
    func getProgression(using progressions: AchievementsProgression, _ banner: Banner) -> AchievementProgression? {
        forKey(banner).accessibility.progression(using: progressions)
    }
    func getProgression(using progressions: AchievementsProgression, _ profileImage: ProfileImage) -> AchievementProgression? {
        forKey(profileImage).accessibility.progression(using: progressions)
    }
}

// MARK: - CONTENT DATA

// Asset name
enum Title: String, CaseIterable {
    case newLeaf = "New leaf"
    case wordConqueror = "Word Conqueror"
    case wordSmith = "Word Smith"
}

enum Banner: String, CaseIterable {
    case PB_0
    case PB_1
    case PB_3
    case PB_4
    case PB_5
    case PB_6
    case PB_7
    case PB_8
    case PB_9
    case PB_10
    case PB_11
    case PB_12
    case PB_13
    case PB_14
    case PB_15
}

enum ProfileImage: String, CaseIterable {
    case PI_0
    case PI_1
    case PI_2
    case PI_3
    case PI_4
    case PI_5
    case PI_6
    case PI_7
    case PI_8
    case PI_9
    case PI_10
    case PI_11
    case PI_12
    case PI_13
    case PI_14
    case PI_15
    case PI_16
}

extension ContentRepository {
    func forKey(_ key: Title) -> TitleItem {
        switch key {
        case .newLeaf:
            TitleItem(
                display: key.rawValue,
                description: "Title For a new leaf",
                accessibility: .base
            )
        case .wordConqueror:
            TitleItem(
                display: key.rawValue,
                description: "Title for a word conqueror",
                accessibility: .unlockable(source: .achievement(.wordConqueror))
            )
        case .wordSmith:
            TitleItem(
                display: key.rawValue,
                description: "Title For a word smith",
                accessibility: .unlockable(source: .achievement(.wordSmith))
            )
        }
    }
    
    func forKey(_ key: Banner) -> BannerItem {
        switch key {
        case .PB_0:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_1:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for a word conqueror",
                accessibility: .unlockable(source: .achievement(.wordConqueror))
            )
        case .PB_3:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for a wordsmith",
                accessibility: .unlockable(source: .achievement(.wordSmith))
            )
        case .PB_4:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_5:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_6:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_7:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_8:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_9:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_10:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_11:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_12:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_13:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_14:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .PB_15:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        }
    }
    
    func forKey(_ key: ProfileImage) -> ProfileImageItem {
        switch key {
        case .PI_0:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 0",
                accessibility: .base
            )
        case .PI_1:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "image 1",
                accessibility: .unlockable(source: .achievement(.wordConqueror))
            )
        case .PI_2:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "image 2",
                accessibility: .unlockable(source: .achievement(.wordSmith))
            )
        case .PI_3:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 3",
                accessibility: .base
            )
        case .PI_4:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 4",
                accessibility: .base
            )
        case .PI_5:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 5",
                accessibility: .base
            )
        case .PI_6:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 6",
                accessibility: .base
            )
        case .PI_7:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 7",
                accessibility: .base
            )
        case .PI_8:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 8",
                accessibility: .base
            )
        case .PI_9:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 9",
                accessibility: .base
            )
        case .PI_10:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 10",
                accessibility: .base
            )
        case .PI_11:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 11",
                accessibility: .base
            )
        case .PI_12:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 12",
                accessibility: .base
            )
        case .PI_13:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 13",
                accessibility: .base
            )
        case .PI_14:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 14",
                accessibility: .base
            )
        case .PI_15:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 15",
                accessibility: .base
            )
        case .PI_16:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 16",
                accessibility: .base
            )
        }
    }
    
    private func loadContentItems() {
        
        // Load titles
        Title.allCases.forEach { titleEnum in
            let titleItem = self.forKey(titleEnum)
            titles.addItem(titleItem)
        }
        
        // Load banners
        Banner.allCases.forEach { bannerEnum in
            let bannerItem = self.forKey(bannerEnum)
            banners.addItem(bannerItem)
        }
        
        // Load profile images
        ProfileImage.allCases.forEach { profileImageEnum in
            let profileImageItem = self.forKey(profileImageEnum)
            profileImages.addItem(profileImageItem)
        }
    }
}

// MARK: - QUERY REPOSITORY
extension ContentRepository {
    
    func query() -> ContentQuery {
        return ContentQuery(manager: self)
    }
    
    class ContentQuery {
        private var manager: ContentRepository
        private var sourceFilter: ContentSource?
        private var unlocked: Bool = false
        private var typeFilter: ContentTypeFilter = .all
        private let logger = Logger(subsystem: "com.WordRivalry", category: "ContentQuery")
        
        struct ContentTypeFilter: OptionSet {
            let rawValue: Int
            
            static let banner = ContentTypeFilter(rawValue: 1 << 0)
            static let title = ContentTypeFilter(rawValue: 1 << 1)
            static let profileImage = ContentTypeFilter(rawValue: 1 << 2)
            static let all: ContentTypeFilter = [.banner, .title, .profileImage]
            
            // Convenience combinations
            static let bannerAndTitle: ContentTypeFilter = [.banner, .title]
            static let titleAndProfileImage: ContentTypeFilter = [.title, .profileImage]
            static let bannerAndProfileImage: ContentTypeFilter = [.banner, .profileImage]
        }
        
        init(manager: ContentRepository) {
            self.manager = manager
        }
        
        func bySource(_ source: ContentSource) -> ContentQuery {
            self.sourceFilter = source
            return self
        }
        
        func only(_ filter: ContentTypeFilter) -> ContentQuery {
            self.typeFilter = filter
            return self
        }
        
        func execute() -> [ContentItem] {
            var results: [ContentItem] = []
            
            if typeFilter.contains(.banner) {
                results += manager.banners.applyFilters(source: sourceFilter)
            }
            if typeFilter.contains(.title) {
                results += manager.titles.applyFilters(source: sourceFilter)
            }
            if typeFilter.contains(.profileImage) {
                results += manager.profileImages.applyFilters(source: sourceFilter)
            }
            
            self.logger.debug("Query effectued")
            
            return results
        }
    }
}

// MARK: - STORE
class ContentStore<T: ContentItem> {
    private var items: [String: T] = [:]
    
    func addItem(_ item: T) {
        items[item.id] = item
    }
    
    func getItem(by id: String) -> T? {
        return items[id]
    }
    
    func getAllItems() -> [T] {
        return Array(items.values)
    }
}

// MARK: - QUERY STORE
extension ContentStore {
    func applyFilters(source: ContentSource?) -> [T]  {
        var query = self.query()
        if let source = source {
            query = query.bySource(source)
        }
        return query.execute()
    }
    
    private func query() -> ContentQuery {
        return ContentQuery(items: getAllItems())
    }
    
    private class ContentQuery {
        private var items: [T]
        
        init(items: [T]) {
            self.items = items
        }
        
        func bySource(_ source: ContentSource) -> ContentQuery {
            let filteredItems = items.filter {
                switch $0.accessibility {
                case .unlockable(let itemSource) where itemSource == source:
                    return true
                default:
                    return false
                }
            }
            return ContentQuery(items: filteredItems)
        }
        
        func execute() -> [T] {
            return items
        }
    }
}
