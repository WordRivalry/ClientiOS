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
        let schema = Schema([Profile.self, MatchHistoric.self])
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = container.mainContext
        
        let profile = Profile.preview
        let matches = MatchHistoric.previews

        if try modelContext.fetch(FetchDescriptor<Profile>()).isEmpty {
            container.mainContext.insert(profile)
        }
        
        if try modelContext.fetch(FetchDescriptor<MatchHistoric>()).isEmpty {
            matches.forEach { match in
                container.mainContext.insert(match)
            }
        }
        
        print("Preview container initiated")
        return container
    } catch {
        fatalError(error.localizedDescription)
    }
}()
