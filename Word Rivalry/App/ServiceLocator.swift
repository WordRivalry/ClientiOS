//
//  ServiceLocator.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import os.log

final class ServiceLocator {
    private let logger = Logger(subsystem: "com.WordRivalry", category: "ServiceLocator")
    private(set) var audioService:          AudioService
    private(set) var audioSessionService:   AudioSessionService
    private(set) var swiftDataService:      SwiftDataService
    private(set) var launchService:         LaunchService
 
    
    init() {
        self.logger.debug("*** ServiceLocator STARTED ***")
        self.swiftDataService       = .init()
        self.audioService           = .init()
        self.audioSessionService    = .init(audioService: self.audioService)
        self.launchService          = .init(dataService: self.swiftDataService)
    }
}
