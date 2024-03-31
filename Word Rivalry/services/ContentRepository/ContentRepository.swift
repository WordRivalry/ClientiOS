//
//  RewardManagaer.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import Foundation

// MARK: - CONTENT DEFINITION
enum ContentAccessibility {
    case base // Content id
    case unlockable(source: ContentSource)
}

enum ContentSource: Equatable {
    case achievement(AchievementName)  // Tied to an achievement
}

protocol ContentItem {
    var id: String { get }
    var description: String { get }
    var accessibility: ContentAccessibility { get }
}

struct TitleItem: ContentItem {
    var id: String { display }
    var display: String
    var description: String
    var accessibility: ContentAccessibility
}

struct ProfileImageItem: ContentItem {
    var id: String { assetName }
    var assetName: String
    var description: String
    var accessibility: ContentAccessibility
}

struct BannerItem: ContentItem {
    var id: String { assetName }
    var assetName: String
    var description: String
    var accessibility: ContentAccessibility
}

// MARK: - REPOSITORY
class ContentRepository {
    static let shared = ContentRepository()
    var banners: ContentStore<BannerItem>
    var titles: ContentStore<TitleItem>
    var profileImages: ContentStore<ProfileImageItem>
    
    init() {
        // Initialize stores
        banners = ContentStore<BannerItem>()
        titles = ContentStore<TitleItem>()
        profileImages = ContentStore<ProfileImageItem>()
        loadContentItems()
    }
}

// MARK: - CONTENT DATA

// Asset name
enum Title: String, CaseIterable {
    case newLeaf
    case wordConqueror
    case wordSmith
}

enum Banner: String, CaseIterable {
    case defaultProfileBanner
    case wordConquerorBanner
    case wordSmithBanner
}

enum ProfileImage: String, CaseIterable {
    case PI_0
    case PI_1
    case PI_2
    case PI_3
    case PI_4
    case PI_5
    case PI_6
}

extension ContentRepository {
    func forKey(_ key: Title) -> TitleItem {
        switch key {
        case .newLeaf:
            TitleItem(
                display: "New Leaf",
                description: "Title For a new leaf",
                accessibility: .base
            )
        case .wordConqueror:
            TitleItem(
                display: "Word Conqueror",
                description: "Title for a word conqueror",
                accessibility: .unlockable(source: .achievement(.wordConqueror))
            )
        case .wordSmith:
            TitleItem(
                display: "Word Smith",
                description: "Title For a word smith",
                accessibility: .unlockable(source: .achievement(.wordSmith))
            )
        }
    }
    
    func forKey(_ key: Banner) -> BannerItem {
        switch key {
        case .defaultProfileBanner:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default",
                accessibility: .base
            )
        case .wordConquerorBanner:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for a word conqueror",
                accessibility: .unlockable(source: .achievement(.wordConqueror))
            )
        case .wordSmithBanner:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for a wordsmith",
                accessibility: .unlockable(source: .achievement(.wordSmith))
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
