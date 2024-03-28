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
        let container = try ModelContainer(
            for: Profile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<Profile>()).isEmpty {
            container.mainContext.insert(Profile.preview)
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
