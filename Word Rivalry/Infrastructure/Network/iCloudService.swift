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
    
    let db = PublicDatabase.shared.db
    
    private init() {}
    
    func checkICloudStatus() {
        Task {
            self.iCloudStatus = try? await db.getICloudAccountStatus()
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
    
    func start() async -> String {
        
        self.iCloudStatus = try? await db.getICloudAccountStatus()
        
        while self.iCloudStatus != .available {
            if GlobalOverlay.shared.overlay != .noIcloudAccount {
                Task { @MainActor in
                    GlobalOverlay.shared.overlay = .noIcloudAccount
                }
            }

            // Sleep for 1 sec before checking again
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            self.iCloudStatus = try? await db.getICloudAccountStatus()
        }

        if GlobalOverlay.shared.overlay != .closed {
            Task { @MainActor in
                GlobalOverlay.shared.overlay = .closed
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
