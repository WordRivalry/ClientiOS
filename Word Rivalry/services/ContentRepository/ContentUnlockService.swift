////
////  ContentUnlockService.swift
////  Word Rivalry
////
////  Created by benoit barbier on 2024-03-30.
////
//
//import Foundation
//
//struct ContentUnlockConfig: Decodable {
//    let contentUnlocks: [ContentUnlock]
//}
//
//struct ContentUnlock: Decodable {
//    let id: String
//    let type: String
//    let unlockCondition: UnlockCondition
//}
//
//struct UnlockCondition: Decodable {
//    let achievementId: String?
//    let actionId: String?
//    let specialEventId: String?
//}
//
//class ContentUnlockSystem {
//    let unlockConfigs: [ContentUnlock]
//
//    init(config: ContentUnlockConfig) {
//        self.unlockConfigs = config.contentUnlocks
//    }
//
//    func checkUnlocks(for profile: Profile) {
//        unlockConfigs.forEach { unlockConfig in
//            if let achievementId = unlockConfig.unlockCondition.achievementId,
//                profile.unlockedCAchievementIDs.contains(achievementId) {
//                profile.unlockedContentIDs.append(unlockConfig.id)
//            }
//            if let specialEventId = unlockConfig.unlockCondition.specialEventId,
//                profile.completedSpecialEventIDs.contains(specialEventId) {
//                profile.unlockedContentIDs.append(unlockConfig.id)
//            }
//        }
//    }
//}
//
