//
//  PersonalProfile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-14.
//

import Foundation
import OSLog

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the Personal Profile events from the app
    static let personnalProfile = Logger(subsystem: subsystem, category: "PersonalProfile")
}


class PersonalProfile {
    var source: SYPData<Profile>?
    var profile: Profile?
    
    init() {
        Task { @MainActor in
            self.source = SYPData<Profile>()
        }
    }
    
    func loadProfile() {
        guard self.profile == nil else { return }
        
        guard let source = self.source else { return }
        
        let profiles = source.fetchItems()
        if profiles.count >= 1 {
            Logger.personnalProfile.error("\(profiles.count) Profiles found!")
            self.profile = profiles[0]
        } else {
            Logger.personnalProfile.info("Profile not found")
            self.profile = nil
        }
    }
    
    func getProfile() -> Profile? {
        if let profile = self.profile {
            return profile
        } else {
            loadProfile()
            return self.profile
        }
    }
    
    func createProfile() {
        guard let source = self.source else {
            Logger.personnalProfile.fault("Precondition check failed for creation: No source.")
            return
        }
        
        guard NetworkChecker.shared.isConnected == true else {
            Logger.personnalProfile.fault("Precondition check failed for creation: No internet.")
            return
        }
        
        let noProfileFound = getProfile() == nil
        
        guard noProfileFound == true else {
            Logger.personnalProfile.fault("Precondition check failed for creation: Already exist.")
            return
        }
        
        let profile = Profile.new
        source.appendItem(profile)
        self.profile = profile
        
        Logger.personnalProfile.info("Personnel Profile created")
    }
}

extension PersonalProfile: AppService {
    var isHealthy: Bool {
        get {
            self.source != nil && self.profile != nil
        }
        set {
            //
        }
    }
    
    var identifier: String {
        "PersonalProfile"
    }
    
    var startPriority: ServiceStartPriority {
        .critical(0)
    }
    
    func start() async throws -> String {
        self.loadProfile()
        if self.isHealthy {
            return "Personal profile status - Ready : \(self.profile != nil)"
        }
      
        self.createProfile()
        if self.isHealthy {
            return "Personal profile status - Ready : \(self.profile != nil)"
        }
        
        return "Personal profile status - Ready : \(self.profile != nil)"
    }
    
    func handleAppBecomingActive() {
        //
    }
    
    func handleAppGoingInactive() {
        //
    }
    
    func handleAppInBackground() {
        //
    }
}
