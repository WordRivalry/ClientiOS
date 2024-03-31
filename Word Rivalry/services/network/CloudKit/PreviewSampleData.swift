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
//        let schema = Schema([Profile.self, AchievementProgression.self])
//        let container = try ModelContainer(
//            for: schema,
//            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//        )
//        let modelContext = container.mainContext
//        if try modelContext.fetch(FetchDescriptor<Profile>()).isEmpty {
//            container.mainContext.insert(Profile.preview)
//        }
//        if try modelContext.fetch(FetchDescriptor<AchievementProgression>()).isEmpty {
//            container.mainContext.insert(AchievementProgression.preview)
//        }
//        return container
        
        let schema = Schema([Profile.self, AchievementProgression.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let sampleData: [any PersistentModel] = [
            Profile.preview, AchievementProgression.preview
        ]
        Task { @MainActor in
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        }
        return container
}()

//@MainActor
//let previewContainer: ModelContainer = {
//    
//    do {
//        let container = try ModelContainer(for: Budget.self, ModelConfiguration(inMemory: true))
//        SampleData.budgets.enumerated().forEach { index, budget in
//            container.mainContext.insert(budget)
//            let transaction = Transaction(note: "Note \(index + 1)", amount: (Double(index) * 10), date: Date())
//            budget.addTransaction(transaction)
//        }
//        
//        return container
//        
//    } catch {
//        fatalError("Failed to create container.")
//    }
//}()
//
//struct SampleData {
//    static let budgets: [Budget] = {
//        return (1...5).map { Budget(name: "Budget \($0)", limit: 100 * Double($0)) }
//    }()
//}
