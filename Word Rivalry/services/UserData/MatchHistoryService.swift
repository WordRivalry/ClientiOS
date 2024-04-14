////
////  MatchHistory.swift
////  Word Rivalry
////
////  Created by benoit barbier on 2024-04-13.
////
//
//import Foundation
//import OSLog
//
//@Observable final class MatchHistoryService: JITData, AppService {
//    var isHealthy: Bool = true
//    var identifier: String = "MatchHistoryService"
//    var startPriority: ServiceStartPriority = .nonCritical(Int.max)
//    func start() async throws -> String {
//        return "JIT Data do no require set up."
//    }
//    
//    var historic: [Match] = []
//      
//    @MainActor
//    override func fetchData() async {
//        do {
//            self.historic = try await fetchMatchesHistoric()
//            Logger.dataServices.info("Matches historic updated")
//        } catch {
//            Logger.dataServices.error("Failed to fetch matches historic: \(error.localizedDescription)")
//        }
//    }
//    
//    override func isDataAvailable() -> Bool {
//        if historic.isEmpty {
//            return false
//        }
//        return true
//    }
//    
//    private func fetchMatchesHistoric() async throws -> [Match] {
//        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
//        return try await PublicDatabase.shared.fetchGamesHistoric(limit: 50)
//    }
//    
//    static var preview: MatchHistoryService {
//        let service = MatchHistoryService()
//        service.historic = Match.previews
//        return service
//    }
//}
