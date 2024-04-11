//
//  log.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the scene events from the app
    static let sceneEvents = Logger(subsystem: subsystem, category: "sceneEvents")
    
    /// Logs the service manager actions
    static let serviceManager = Logger(subsystem: subsystem, category: "dataServices")
    
    /// Logs the data services actions
    static let dataServices = Logger(subsystem: subsystem, category: "dataServices")
    
    /// Logs the view cycles like a view that appeared.
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")

    /// All logs related to tracking and analytics.
    static let statistics = Logger(subsystem: subsystem, category: "statistics")
    
    /// Logs the timer events from the app
    static let timer = Logger(subsystem: subsystem, category: "timer")
    
    /// Logs the audio events from the app
    static let audio = Logger(subsystem: subsystem, category: "audio")
    

}
