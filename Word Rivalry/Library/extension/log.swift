//
//  log.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the app events from the app
    static let appEvents = Logger(subsystem: subsystem, category: "appEvents")
    
    /// Logs the service manager actions
    static let serviceManager = Logger(subsystem: subsystem, category: "dataServices")
    
    /// Logs the data services actions
    static let dataServices = Logger(subsystem: subsystem, category: "dataServices")
    
    /// Logs the CloudKitManager actions
    static let cloudKit = Logger(subsystem: subsystem, category: "CloudKitManager")
    
    /// Logs the view cycles like a view that appeared.
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")

    /// All logs related to tracking and analytics.
    static let statistics = Logger(subsystem: subsystem, category: "statistics")
    
    /// Logs the timer events from the app
    static let timer = Logger(subsystem: subsystem, category: "timer")
    
    /// Logs the audio events from the app
    static let audio = Logger(subsystem: subsystem, category: "audio")
    
    /// Logs the AppDelegate events from the app
    static let appDelegate = Logger(subsystem: subsystem, category: "AppDelegate")
    
    /// Logs the Match events from the app
    static let match = Logger(subsystem: subsystem, category: "Match")
    
    /// Logs the publicProfile event
    static let publicProfile = Logger(subsystem: subsystem, category: "publicProfile")
}
