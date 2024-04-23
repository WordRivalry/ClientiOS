//
//  AppServiceProtocol.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import OSLog

protocol ServiceLifeCycle: SceneLifeCycle {
    /// This method is called during application startup phase.
    /// It should either succeed and mark the service as healty, or simply return any log.
    ///
    /// ```
    ///  override func start() async -> String {
    ///         // do work
    ///         self.isHealthy = true
    ///         return "log message, could be an error"
    ///  }
    /// ```
    ///
    /// - Returns: A log message
    func start() async throws -> String
}

protocol AppService: AnyObject, ServiceLifeCycle {
    
    /// This flag determinates if a service is ready to opperate.
    var isHealthy: Bool { get set }
    
    /// Unique identifier used for logging purposes.
    var identifier: String { get }
    
    /// Define the priority whithin the current batch of sibling services
    var startPriority: ServiceStartPriority { get }
}

extension AppService {

    /// Default recovery implementation
    /// Uses self.start() internally
    func recover() async -> Bool {
        var attemptCount = 0
        let maxRetries = 3

        repeat {
            do {
                Logger.serviceManager.log("Attempting to restart \(self.identifier)")
                _ = try await start()
                self.isHealthy = true
                return true
            } catch {
                Logger.serviceManager.log(level: .error, "Failed to recover \(self.identifier): \(error.localizedDescription)")
                self.isHealthy = false
                attemptCount += 1
            }
        } while !self.isHealthy && attemptCount < maxRetries
        
        return false
    }
}

enum ServiceStartPriority {
    case critical(Int)
    case nonCritical(Int)
    
    /// Computed property to check if the start priority is critical
    var isCritical: Bool {
        switch self {
        case .critical:
            return true
        case .nonCritical:
            return false
        }
    }
    
    /// Computed property to provide a description string
    var description: String {
        switch self {
        case .critical(let priority):
            return "Critical - Level \(priority)"
        case .nonCritical(let priority):
            return "Non-Critical - Level \(priority)"
        }
    }
}

extension ServiceStartPriority: Comparable {
    static func < (lhs: ServiceStartPriority, rhs: ServiceStartPriority) -> Bool {
        switch (lhs, rhs) {
        case let (.critical(lhsPriority), .critical(rhsPriority)):
            return lhsPriority < rhsPriority
        case (.critical, _):
            return true
        case (_, .critical):
            return false
        case let (.nonCritical(lhsPriority), .nonCritical(rhsPriority)):
            return lhsPriority < rhsPriority
        default:
            return false
        }
    }
}


