//
//  SYPData.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-13.
//

import Foundation
import OSLog
import SwiftData

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the SYP Data events from the app
    static let sypData = Logger(subsystem: subsystem, category: "SYPData")
}

import Foundation

/// `SYPData` is a generic observable class designed to manage a synchronized yet persisted (SYP)
/// data model that is synchronized across devices while also persisting data. This class is
/// ideal for applications requiring a consistent state across multiple platforms while ensuring
/// that data remains stored locally on each device.
///
/// This class leverages generic constraints to ensure that it only handles types conforming to both
/// `PersistentModel` and `DataPreview`, facilitating easy preview and persistence.
///
/// - Parameters:
///     - T: The type of the data model, which must conform to `PersistentModel` and `DataPreview`.
@Observable class SYPData<T: PersistentModel & DataPreview> {
    
    /// Provides a static preview instance of `SYPData` populated with default data, primarily used
    /// for SwiftUI previews or testing purposes. This static method initializes a new instance,
    /// fetches existing items, and if none are present, populates it with preview data from the model.
    @MainActor
    static var preview: SYPData<T> {
        let dataManager = SYPData<T>()
        let fetchResults = dataManager.fetchItems()
        if fetchResults.isEmpty {
            print("Populating preview data")
            dataManager.appendItem(T.preview)
            dataManager.save()
        }
        return dataManager
    }
    
    /// A private property that holds the actual data source. This property is not observable to
    /// ensure changes are only published through controlled means within this class.
    @ObservationIgnored
    private var swiftData: SDSource
    
    var data: [T] = []
    
    /// Indicates whether the data manager is fully initialized and ready to be used. This flag helps
    /// ensure that operations on the data manager do not occur before it is fully set up.
    var isReady: Bool = false
    
    /// Initializes a new instance of the data manager by fetching the shared instance of the data source
    /// and setting the `isReady` flag to true. This setup ensures that the data manager is operational
    /// immediately upon initialization.
    @MainActor
    init() {
        self.swiftData = SDSource.sharedInstance
        self.isReady = true
        self.data = self.fetchItems()
    }
    
    /// Saves changes in the current context. This method is a part of the
    /// synchronizing/persistence layer that helps maintain data integrity and consistency across sessions.
    func save() {
        self.precondition()
        self.swiftData.saveContext()
    }
    
    /// Appends a new item to the data source.
    func appendItem(_ item: T) {
        self.precondition()
        self.swiftData.appendItem(item)
        self.swiftData.saveContext()
        self.data = self.fetchItems()
    }
    
    /// Fetches all items of type `T` from the data source.
    func fetchItems() -> [T] {
        self.precondition()
        return self.swiftData.fetchItems()
    }
    
    /// Removes a specified item from the data source
    func removeItem(_ item: T) {
        self.precondition()
        self.swiftData.removeItem(item)
        self.swiftData.saveContext()
        self.data = self.fetchItems()
    }
    
    func precondition() {
        guard self.isReady == true else {
            fatalError("The precondition check failed: SYPData<\(T.Type.self)> - ready: \(self.isReady)")
        }
    }
}
