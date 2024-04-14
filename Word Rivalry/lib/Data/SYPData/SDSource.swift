//
//  SDSource.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-14.
//

import Foundation
import SwiftData
import OSLog

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the Swift Data Source  events from the app
    static let SDSource = Logger(subsystem: subsystem, category: "SDSource")
}

@Observable class SDSource {
    private var modelContainer: ModelContainer
    let modelContext: ModelContext
    
    @MainActor
    static var sharedInstance = SDSource()
    
    @MainActor
    private init() {
        let container = try! ModelContainer(
            for: Profile.self, MatchHistoric.self,
            configurations: ModelConfiguration(cloudKitDatabase: .private("iCloud.WordRivalryContainer"))
        )
        self.modelContainer = container
        self.modelContext = container.mainContext
    }
    
    func fetchItems<T: PersistentModel>() -> [T] {
        do {
            let ret = try modelContext.fetch(FetchDescriptor<T>())
            Logger.SDSource.debug("Ctx item fetched ")
            return ret;
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func appendItem<T: PersistentModel>(_ item: T) {
        modelContext.insert(item)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        Logger.SDSource.debug("Ctx data inserted and saved")
     }

     func removeItem<T: PersistentModel>(_ item: T) {
         modelContext.delete(item)
         Logger.SDSource.debug("Ctx item deleted ")
     }

     func saveContext() {
         do {
             try modelContext.save()
         } catch {
             fatalError(error.localizedDescription)
         }
         Logger.SDSource.debug("Ctx saved")
     }
}
