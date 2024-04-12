//
//  PreviewSampleData.swift
//  Word Rivalry
//
//  // by appple not Created by benoit barbier on 2024-03-28.
//

import SwiftData
import SwiftUI

/**
 Preview sample data.
 */
@MainActor
let previewContainer: ModelContainer = {
    do {
        let schema = Schema([Profile.self, Friend.self, GameHistory.self])
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = container.mainContext
        
        let profile = Profile.preview
        let gameHistories = GameHistory.previews
        let friends = Friend.preview

        if try modelContext.fetch(FetchDescriptor<Profile>()).isEmpty {
            container.mainContext.insert(profile)
        }
        
        if try modelContext.fetch(FetchDescriptor<GameHistory>()).isEmpty {
            gameHistories.forEach { gameHistoric in
                container.mainContext.insert(gameHistoric)
            }
        }
        
        if try modelContext.fetch(FetchDescriptor<Friend>()).isEmpty {
            friends.forEach { friend in
                container.mainContext.insert(friend)
            }
        }
        
        print("Preview container initiated")
        return container
    } catch {
        fatalError(error.localizedDescription)
    }
}()
