//
//  MyPersonalProfile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-16.
//

import Foundation
import OSLog
import CloudKit

/// `MyPersonalProfile` handles the user's personal profile, interfacing with CloudKit to fetch, create, and update profiles.
/// It also listens for relevant CloudKit notifications to update the profile data asynchronously.
@Observable final class MyPersonalProfile: DataPreview {
    
    // MARK: DataPreview
    
    static var preview: MyPersonalProfile = {
        let service = MyPersonalProfile()
        service.personalProfile = PersonalProfile.preview
        return service
    }()
    
    // MARK: variables
    
    /// Holds the current user's public profile, defaulting to a null profile state.
    var personalProfile: PersonalProfile = PersonalProfile.preview
    
    /// Reference to the shared database instance.
    let db = PublicDatabase.shared.db
    
    /// Stores pending updates that need to be applied to the public profile.
    private var pendingUpdates: [String: Any] = [:]
    
    /// Boolean to determinate if the view is in the view tree of randering
    private var isOnViewTree: Bool = false
    
    // MARK: init deinit
    
    /// Initializes `MyPublicProfile` and registers it to listen for `modelUpdated` notifications from CloudKit.
    /// Notifications are used to update the local profile state based on changes in the remote database.
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileUpdateNotification(_:)),
            name: .modelUpdated,
            object: nil // Listen for notifications from any object
        )
    }
    
    /// Cleans up by removing the object as an observer.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notification Handling
    
    /// Handles incoming notifications about profile updates by storing the updates to be applied later.
    /// - Parameter notification: The notification containing updated profile fields.
    @objc private func handleProfileUpdateNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let recordID = userInfo["recordID"] as? CKRecord.ID,
              let updatedFields = notification.object as? [String: Any]?
        else {
            Logger.personalProfile.fault("Record Update failure to receive for handling")
            return
        }
        
        guard self.personalProfile.recordID.recordName == recordID.recordName else {
            Logger.personalProfile.info("RecordID [\(recordID.recordName)] do not match [\(self.personalProfile.recordID.recordName)]")
            return
        }
        
        guard let updatedFields = updatedFields else {
            Logger.personalProfile.info("RecordID [\(recordID)], empty update fields")
            return
        }
        
        Logger.personalProfile.info("RecordType [\(PersonalProfile.recordType)] RecordID [\(recordID)] do match [\(self.personalProfile.recordID)]")
        
        // Store the updates to be applied later
        for (key, value) in updatedFields {
            pendingUpdates[key] = value
            
            Logger.personalProfile.info("Key: \(key)")
        }
        
        // Apply updates immediately if the view is visible
        if isOnViewTree {
            self.applyPendingUpdates()
        }
    }
    
    private func applyPendingUpdates() {
        guard !pendingUpdates.isEmpty else { return }
        
        // Apply each pending update to the current user
        for (key, value) in pendingUpdates {
            if let keyEnum = PersonalProfile.Key(rawValue: key) {
                applyUpdates(key: keyEnum, value: value)
            }
        }
        
        // Clear pending updates after applying
        pendingUpdates.removeAll()
    }
    
    private func applyUpdates(key: PersonalProfile.Key, value: Any) {
        switch key {
        case .currency:
            personalProfile.currency = value as? Int ?? personalProfile.currency
        }
    }
    
    // MARK: Profile Handling

    /// Attempts to fetch or create the public profile depending on its existence in the CloudKit database.
    private func findOrCreateProfile() async throws {
        guard NetworkChecker.shared.isConnected else {
            Logger.personalProfile.fault("No Connection to internet found...")
            return
        }
        
        do {
            self.personalProfile = try await fetchPlayer()
            Logger.personalProfile.info("Personal profile exist")
        } catch {
            Logger.personalProfile.fault("Failed to fetch Personal profile")
        }
    }
    
    /// Fetches the player's public profile from CloudKit based on the user's record ID.
    private func fetchPlayer() async throws -> PersonalProfile {
        let userID = try await db.userRecordID()
        return try await db.fetchModelByRecordName(with: userID.recordName)
    }
    
    func addCurrency(amountToAdd: Int) async throws {
        _ = try await self.updateCurrency(saving: self.personalProfile.currency + amountToAdd)
    }
    
    func subtractCurrency(amountToSubtract: Int) async throws {
        let newAmount = self.personalProfile.currency - amountToSubtract
        try validateCurrency(newAmount)
        _ = try await self.updateCurrency(saving: newAmount)
    }
    
    func updateCurrency(saving currency: Int) async throws -> PersonalProfile {
        return try await db.update(for: self.personalProfile, field: .currency, with: currency)
    }
    
    func validateCurrency(_ currency: Int) throws  {
        guard currency >= 0 else {
            throw PersonalProfileDatabaseError.negativeCurrencyUpdate
        }
    }
    
    enum PersonalProfileDatabaseError: Error {
        case negativeCurrencyUpdate
        case invalidDataType
    }
    
    // MARK: Subscription
    
    func subscribeToModelUpdates() async throws {
        try await db.subscribeToModelUpdates(model: self.personalProfile)
    }
}

// MARK: AppService
extension MyPersonalProfile: AppService {
    var isHealthy: Bool {
        get { !(self.personalProfile.currency == -1) }
        set {}
    }
    
    var identifier: String { "MyPersonalProfile" }
    var startPriority: ServiceStartPriority { .critical(3) }
    
    func start() async throws -> String {
        let userID = try await db.userRecordID()
        self.personalProfile = try await db.fetchModelByRecordName(with: userID.recordName)
        
        if isHealthy {
            try await subscribeToModelUpdates()
        }
        
        return "MyPersonalProfile: \(self.personalProfile)"
    }
    
    func handleAppBecomingActive() { }
    func handleAppGoingInactive() { }
    func handleAppInBackground() { }
}

// MARK: ViewLifeCycle
extension MyPersonalProfile: ViewLifeCycle {
    
    /// > Warning:  Only apply this to 1 view, within a continuous View stack.
    /// Did disappear can toggle the isOnViewTree if deeper application is done, which result in the first appliance being voided.
    func handleViewDidDisappear() {
        self.isOnViewTree = false
    }
    
    /// > Warning:  Only apply this to 1 view
    func handleViewDidAppear() {
        self.isOnViewTree = true
        Task { @MainActor in
            self.applyPendingUpdates()
        }
    }
}
