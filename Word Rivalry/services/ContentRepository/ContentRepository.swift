//
//  RewardManagaer.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import Foundation
import os.log

protocol ContentItem {
    var id: String { get }
    var description: String { get }
}

struct TitleItem: ContentItem {
    var id: String { display }
    var display: String
    var description: String
}

struct ProfileImageItem: ContentItem {
    var id: String { assetName }
    var assetName: String
    var description: String
}

struct BannerItem: ContentItem {
    var id: String { assetName }
    var assetName: String
    var description: String
    var requirement: String?
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
    
    func getDescription(for title: Title) -> String {
        forKey(title).description
    }
    func getDescription(for banner: Banner) -> String {
        forKey(banner).description
    }
    func getDescription(for profileImage: ProfileImage) -> String {
        forKey(profileImage).description
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
                description: "Title For a new leaf"
            )
        case .wordConqueror:
            TitleItem(
                display: key.rawValue,
                description: "Title for a word conqueror"
            )
        case .wordSmith:
            TitleItem(
                display: key.rawValue,
                description: "Title For a word smith"
            )
        }
    }
    
    func forKey(_ key: Banner) -> BannerItem {
        switch key {
        case .PB_0:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_1:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for a word conqueror"
            )
        case .PB_3:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for a wordsmith"
            )
        case .PB_4:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_5:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_6:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_7:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_8:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_9:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_10:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_11:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_12:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_13:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_14:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        case .PB_15:
            BannerItem(
                assetName: key.rawValue,
                description: "Banner for default"
            )
        }
    }
    
    func forKey(_ key: ProfileImage) -> ProfileImageItem {
        switch key {
        case .PI_0:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 0"
            )
        case .PI_1:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "image 1"
            )
        case .PI_2:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "image 2"
            )
        case .PI_3:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 3"
            )
        case .PI_4:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 4"
            )
        case .PI_5:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 5"
            )
        case .PI_6:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 6"
            )
        case .PI_7:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 7"
            )
        case .PI_8:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 8"
            )
        case .PI_9:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 9"
            )
        case .PI_10:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 10"
            )
        case .PI_11:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 11"
            )
        case .PI_12:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 12"
            )
        case .PI_13:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 13"
            )
        case .PI_14:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 14"
            )
        case .PI_15:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 15"
            )
        case .PI_16:
            ProfileImageItem(
                assetName: key.rawValue,
                description: "Default image 16"
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
        
        func only(_ filter: ContentTypeFilter) -> ContentQuery {
            self.typeFilter = filter
            return self
        }
        
        func execute() -> [ContentItem] {
            var results: [ContentItem] = []
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
