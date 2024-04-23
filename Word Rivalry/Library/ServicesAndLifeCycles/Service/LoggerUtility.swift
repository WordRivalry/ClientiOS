//
//  LoggerUtility.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import Foundation
import OSLog

class LoggerUtility {
    func logReadyState(services: [AppService], isReady: Bool) {
        if isReady {
            let allServicesIdentifiers = services
                .map { "\($0.identifier) - Ready: \($0.isHealthy)" }
                .joined(separator: "\n")
            info("Services ready:\n\(allServicesIdentifiers)")
        } else {
            let nonReadyServicesDetails = services.filter { !$0.isHealthy }
                                                  .map { "\($0.identifier) - Ready: \($0.isHealthy)" }
                                                  .joined(separator: "\n - ")
            critical("Services not ready:\n[\(nonReadyServicesDetails)]")
        }
    }
    
    func logServiceTree(service: AppService, indentLevel: Int = 0, prefix: String = "") {
        let marker = service.isHealthy ? "🟢" : "🔴"  // Red for critical, green for non-critical
        let details = "\(service.startPriority.description)"
        let line = indentLevel > 0 ? "├── " : ""  // Start with a branch only if it's not the root
        info("\(prefix)\(line)\(marker) \(service.identifier) \(details)")

        if let coordinator = service as? ServiceCoordinator {
            let newPrefix = prefix + (indentLevel > 0 ? "│   " : "    ")  // Continue the line for children or add space
            for (index, subService) in coordinator.services.enumerated() {
                let lastItem = index == coordinator.services.count - 1
                let nextPrefix = lastItem ? prefix + "    " : prefix + "│   "  // Adjust the prefix for the last item
                logServiceTree(service: subService, indentLevel: indentLevel + 1, prefix: newPrefix)
            }
        }
    }

    func log(_ message: String) {
        Logger.serviceManager.log("\(message, privacy: .public)")
    }

    func info(_ message: String) {
        Logger.serviceManager.info("\(message, privacy: .public)")
    }
    
    func notice(_ message: String) {
        Logger.serviceManager.notice("\(message, privacy: .public)")
    }

    func critical(_ message: String) {
        Logger.serviceManager.critical("\(message, privacy: .public)")
    }
    

}
