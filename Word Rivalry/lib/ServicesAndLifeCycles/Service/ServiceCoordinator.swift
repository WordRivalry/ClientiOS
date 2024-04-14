//
//  ServiceCoordinator.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import OSLog

@Observable class ServiceCoordinator: AppService {
  
    init() {}
    
    // MARK: Coordinator members
    
    var subserviceCount: Int = 0
    var messages: [String] = []
    var services: [AppService] = []
    let progressReporter: ProgressReporter = ProgressReporter()
    private let sorter: ServiceSorter = ServiceSorter()
    let logger: LoggerUtility = LoggerUtility()
    
    /// Add a service, increment also the counter
    func addService(_ service: AppService) {
        services.append(service)
      
        if ((service as? ServiceCoordinator) != nil) {
            self.subserviceCount += (service as? ServiceCoordinator)!.subserviceCount
        } else {
            self.subserviceCount += 1
        }
    }

    /// Hook run for precondition check before service start
    func precondition() async -> Bool { return true }
    /// Hook runned after critical services are marked healty
    func onCriticalServicesHealthy() {}
    
    // MARK: AppService members
    
    var identifier: String = ""
    var isHealthy: Bool = false
    var startPriority: ServiceStartPriority = .nonCritical(Int.max)

    // MARK: Service life cycle
    
    func start() async -> String {
        if await !precondition() {
            return "Early return: Precondition didn't check"
        }
        
        if services.isEmpty {
            isHealthy = true
            progressReporter.completeProgress()
            return "No services to start."
        }
        
        let messages = await startAllServices()
        return messages.joined(separator: "\n")
    }

    private func startAllServices() async -> [String] {
        let (criticalServices, nonCriticalServices) = sorter.sortedServices(from: services)
        let messages: [String] = []

        // Start critical services first and ensure they are healthy before proceeding
        await startServices(criticalServices, isCritical: true)
        
        self.isHealthy = criticalServices.allSatisfy({ $0.isHealthy })
        logger.logReadyState(services: criticalServices, isReady: self.isHealthy)
        if (self.isHealthy) {
            self.onCriticalServicesHealthy()
        }
        
        // Start non-critical services without the strict retry and error handling
        await startServices(nonCriticalServices, isCritical: false)

        // Complete the overall progress reporting
        progressReporter.completeProgress()
        
        return messages
    }

    /// Attempts to start a list of services with optional retry logic for critical services.
    private func startServices(_ services: [AppService], isCritical: Bool) async {
        for service in services {
            let message = await attemptToStart(service, isCritical: isCritical)
            Task { @MainActor in
                self.messages.append(message)
            }
        }
    }

    /// Attempts to start a single service, retrying if necessary and throwing an error if a critical service fails to start.
    private func attemptToStart(_ service: AppService, isCritical: Bool) async -> String {
        var attemptCount = 0
        let maxRetries = 3  // Maximum retries for critical services

        repeat {
            do {
                logger.info("Starting: \(service.identifier)...")
                let startupMessage = try await service.start()
                service.isHealthy = true
                progressReporter.updateProgress(for: service)
                return startupMessage
            } catch {
                service.isHealthy = false
                let errorMessage = "Failed to start \(service.identifier): \(error.localizedDescription)"
                Logger.serviceManager.error("\(errorMessage)")

                if isCritical {
                    attemptCount += 1
                    if attemptCount > maxRetries {
                        Logger.serviceManager.error("Critical service \(service.identifier) failed to start after \(maxRetries) attempts.")
                        Task { @MainActor in
                            StartUpViewModel.shared.screen = .error
                        }
                    }
                    try? await Task.sleep(nanoseconds: 500_000_000)
                } else {
                    return errorMessage
                }
            }
        } while isCritical && !service.isHealthy

        return "Service \(service.identifier) started successfully."
    }

    // MARK: Scene life cycle

    func handleAppBecomingActive() {
        services.forEach { $0.handleAppBecomingActive() }
    }
    
    func handleAppGoingInactive() {
        services.forEach { $0.handleAppGoingInactive() }
    }
    
    func handleAppInBackground() {
        services.forEach { $0.handleAppInBackground() }
    }
}
