//
//  PrivateDataAccessManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-24.
//

import Foundation


@Observable final class PrivateDataAccessManager {
    var isAvailable: Bool = false
    
    init () {
        Task {
            self.isAvailable = iCloudService.shared.isHealthy
        }
    }
}
