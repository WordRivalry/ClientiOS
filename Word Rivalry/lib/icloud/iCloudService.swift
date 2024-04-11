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
