//
//  iCloudService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-05.
//

import Foundation
import CloudKit

@Observable final class iCloudService {
    static let shared = iCloudService()
    var iCloudStatus: CKAccountStatus?
    
    private init() {}
    
    func checkICloudStatus() {
        Task {
            self.iCloudStatus = try? await PublicDatabase.shared.iCloudAccountStatus()
        }
    }
    
    func statusMessage() -> String {
        switch iCloudStatus {
        case .available:
            return "Available"
        case .couldNotDetermine:
            return "Could not determine"
        case .noAccount:
            return "No account"
        case .restricted:
            return "Restricted"
        case .temporarilyUnavailable:
            return "Temporarily unavailable"
        case .none:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }
}

extension iCloudService: AppService {
    var isHealthy: Bool {
        get {
            self.iCloudStatus != nil
        }
        set {
            //
        }
    }
    
    func healthCheck() async -> Bool {
        self.isHealthy
    }
    
    var identifier: String {
        "iCloudService"
    }
    
    var startPriority: ServiceStartPriority {
        .critical(1)
    }
    
    var subserviceCount: Int {
        0
    }
    
    func start() async -> String {
        
        self.iCloudStatus = try? await PublicDatabase.shared.iCloudAccountStatus()
        
        while self.iCloudStatus != .available {
            if StartUpViewModel.shared.screen != .noIcloud {
                Task { @MainActor in
                    StartUpViewModel.shared.screen = .noIcloud
                }
            }

            // Sleep for 1 sec before checking again
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            self.iCloudStatus = try? await PublicDatabase.shared.iCloudAccountStatus()
        }

        if StartUpViewModel.shared.screen != .loading {
            Task { @MainActor in
                StartUpViewModel.shared.screen = .loading
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        
        return "iCloud Account Status: \(self.statusMessage())"
    }
    
    func handleAppBecomingActive() {
        self.checkICloudStatus()
    }
    
    func handleAppGoingInactive() {
        // Do nothing
    }
    
    func handleAppInBackground() {
        // Do nothing
    }
}
