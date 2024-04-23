//
//  PublicProfileService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-15.
//

import Foundation
import OSLog
import CloudKit

/// `MyPublicProfile` handles the user's public profile, interfacing with CloudKit to fetch, create, and update profiles.
/// It also listens for relevant CloudKit notifications to update the profile data asynchronously.
@Observable final class MyPublicProfile: DataPreview {
    
    // MARK: DataPreview
    
    static var preview: MyPublicProfile = {
        let service = MyPublicProfile()
        service.publicProfile = User.preview
        return service
    }()
    
    // MARK: variables
    
    /// Holds the current user's public profile, defaulting to a null profile state.
    var user: User = User.nullProfile
    
    /// Stores pending updates that need to be applied to the public profile.
    private var pendingUpdates: [User.Key: Any] = [:]
    
    /// Boolean to determinate if the view is in the view tree of randering
    private var isOnViewTree: Bool = false
    
    private var hasStarted: Bool = false
    
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
    
    // MARK: Profile modifiers
    
    enum PublicProfileError: Error {
        case playerNameUnavailable
        case negativeRating
    }
    
    func changeName(for newPlayerName: String) async throws {
        
        // Ensure the player name is unique
        let alreadyTaken = try await notUnique(newPlayerName)
        if alreadyTaken {
            throw PublicProfileError.playerNameUnavailable
        }
    
        // Proceed to update
        self.publicProfile = try await db.update(
            for: self.publicProfile,
            field: .playerName,
            with: newPlayerName
        )
    }
    
    func addEloPoint(amountToAdd: Int) async throws {
        try await self.updateEloRating(saving: self.publicProfile.eloRating + amountToAdd)
    }
    
    func subtractEloPoint(amountToSubtract: Int) async throws {
        let newAmount = self.publicProfile.eloRating - amountToSubtract
        try validateEloRating(newAmount)
        try await self.updateEloRating(saving: newAmount)
    }
    
    func updateEloRating(saving eloRating: Int) async throws -> Void {
        let updatedProfile = try await db.update(for: self.publicProfile, field: .eloRating, with: eloRating)
        
        Logger.publicProfile.info("Local assignment of pending EloRating update")
        self.pendingUpdates[.eloRating] = updatedProfile.eloRating
    }
    
    func validateEloRating(_ eloRating: Int) throws  {
        guard eloRating >= 0 else {
            throw PublicProfileError.negativeRating
        }
    }
    
    // MARK: Notification Handling
    
    /// Handles incoming notifications about profile updates by storing the updates to be applied later.
    /// - Parameter notification: The notification containing updated profile fields.
    @objc private func handleProfileUpdateNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let recordID = userInfo["recordID"] as? CKRecord.ID,
              let updatedFields = notification.object as? [String: Any]?
        else {
            Logger.publicProfile.fault("Record Update failure to receive for handling")
            return
        }
        
        guard self.publicProfile.recordID.recordName == recordID.recordName else {
            Logger.publicProfile.info("RecordID [\(recordID.recordName)] do not match [\(self.publicProfile.recordID.recordName)]")
            return
        }
        
        guard let updatedFields = updatedFields else {
            Logger.publicProfile.info("RecordID [\(recordID)], empty update fields")
            return
        }
        
        Logger.publicProfile.info("RecordType [\(User.recordType)] RecordID [\(recordID)] do match [\(self.publicProfile.recordID)]")
        
        // Store the updates to be applied later
        for (key, value) in updatedFields {
            if let goodKey = User.Key(rawValue: key) {
                Logger.publicProfile.info("Key: \(key)")
                pendingUpdates[goodKey] = value
            } else {
                Logger.publicProfile.fault("Key: \(key)")
            }
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
            applyUpdates(key: key, value: value)
        }
        
        // Clear pending updates after applying
        pendingUpdates.removeAll()
    }
    
    private func applyUpdates(key: User.Key, value: Any) {
        switch key {
        case .playerName:
            publicProfile.playerName = value as? String ?? publicProfile.playerName
        case .eloRating:
            publicProfile.eloRating = value as? Int ?? publicProfile.eloRating
        case .title:
            publicProfile.title = value as? String ?? publicProfile.title
        case .banner:
            publicProfile.banner = value as? String ?? publicProfile.banner
        case .profileImage:
            publicProfile.profileImage = value as? String ?? publicProfile.profileImage
        case .matchPlayed:
            publicProfile.matchPlayed = value as? Int ?? publicProfile.matchPlayed
        case .matchWon:
            publicProfile.matchWon = value as? Int ?? publicProfile.matchWon
        }
    }
    
    // MARK: Internal Handling

    /// Attempts to fetch or create the public profile depending on its existence in the CloudKit database.
    private func findOrCreateProfile() async throws {
        guard NetworkChecker.shared.isConnected else {
            Logger.publicProfile.fault("No Connection to internet found...")
            return
        }
        
        do {
            self.publicProfile = try await fetchPlayer()
            Logger.publicProfile.info("Public profile exist")
        } catch(ModelToCloudkit.DatabaseError.modelNotFound) {
            Logger.publicProfile.info("Public profile does not exist")
            try await createProfile()
        }
    }
    
    func refresh() -> Void {
        if hasStarted {
            Task { @MainActor in
                self.publicProfile = try await fetchPlayer()
            }
        }
    }
    
    /// Fetches the player's public profile from CloudKit based on the user's record ID.
    private func fetchPlayer() async throws -> User {
        let userID = try await db.userRecordID()
        return try await db.queryModelUserReference(by: userID)
    }
    
    /// Creates a new public profile in CloudKit with a unique player name.
    private func createProfile() async throws {
        guard NetworkChecker.shared.isConnected else {
            Logger.publicProfile.debug("No Connection to internet found...")
            return
        }
        
        var playerName = String(UUID().uuidString.prefix(10))
        
        // Ensure the player name is unique
        while try await notUnique(playerName) {
            playerName = String(UUID().uuidString.prefix(10))
        }
        
        let newPublicProfile = User(
            playerName: playerName
        )
        
        self.publicProfile = try await db.saveModel(saving: newPublicProfile)
        Logger.publicProfile.fault("Public profile created")
    }
    
    /// Checks if the provided player name already exists in the database.
    private func notUnique(_ playerName: String) async throws -> Bool {
        try await !db.isUnique(type: User.self, by: .playerName, value: playerName)
    }
    
    // MARK: Subscription
    
    func subscribeToModelUpdates() async throws {
        try await db.subscribeToModelUpdates(model: self.publicProfile, desiredKeys: [.eloRating, .playerName])
    }
}

// MARK: AppService
extension MyPublicProfile: AppService {
    var isHealthy: Bool {
        get { !self.publicProfile.playerName.isEmpty }
        set {}
    }
    
    var identifier: String { "PublicProfileService" }
    var startPriority: ServiceStartPriority { .critical(3) }
    
    func start() async throws -> String {
        self.publicProfile = try await fetchPlayer()
        
        if isHealthy {
            try await subscribeToModelUpdates()
            hasStarted = true
        }
        
        return "MyPublicProfile: \(self.publicProfile)"
    }
    
    func handleAppBecomingActive() {
        refresh()
    }
    
    func handleAppGoingInactive() { }
    func handleAppInBackground() { }
}

// MARK: ViewLifeCycle
extension MyPublicProfile: ViewLifeCycle {
    
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

