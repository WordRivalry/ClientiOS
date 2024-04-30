//
//  FetchMatchRecords.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-24.
//

import Foundation

///// A use case class for fetching match records from SwiftData.
///// This class adheres to the `UseCaseProtocol`, specifying its core functionality for retrieving list of match records,
//final class FetchMatchRecords: UseCaseProtocol {
//    /// The `Request` type is unused in this case as the fetch operation does not require external input parameters.
//    typealias Request = Void
//    
//    /// The `Response` type is an array of `MatchRecord` objects, which represent individual match histories or results.
//    typealias Response = [MatchRecord]
//    
//    /// Repository for handling data operations related to match records. It uses a `SwiftDataSource` for data handling.
//    @MainActor
//    let recordRepository = MatchRecordRepository(dataSource: SwiftDataSource.shared)
//    
//    /// Executes the fetch operation to retrieve a list of match records.
//    /// - Parameter request: Unused in this method.
//    /// - Returns: An array of `MatchRecord` objects representing match data.
//    /// - Throws: Propagates errors from the data repository if the fetch operation encounters issues.
//    func execute(request: Request = ()) async throws -> Response {
//        
//        let iCloudStatus = iCloudService.shared.iCloudStatus
//        guard iCloudStatus == .available else {
//            return []
//        }
//        
//        return try recordRepository.fetch()
//    }
//}

