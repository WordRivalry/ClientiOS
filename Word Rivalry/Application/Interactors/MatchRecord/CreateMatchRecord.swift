//
//  CreateMatchRecord.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-24.
//

import Foundation


///// A use case class for creating a match record in SwiftData.
///// This class adheres to the `UseCaseProtocol`, specifying its core functionality for creating and storing new match records.
//final class CreateMatchRecord: UseCaseProtocol {
//    /// The `Request` type is `MatchRecord`, which represents the match data to be stored in the database.
//    typealias Request = MatchRecord
//    
//    /// The `Response` type is a `MatchRecord` object, representing the successfully created match record.
//    typealias Response = MatchRecord
//    
//    /// Repository for handling data operations related to match records. It uses a `SwiftDataSource` for data handling.
//    @MainActor
//    let recordRepository = MatchRecordRepository(dataSource: SwiftDataSource.shared)
//    
//    /// Executes the operation to create a new match record.
//    /// - Parameter request: The `MatchRecord` data to be stored.
//    /// - Returns: The `MatchRecord` object representing the newly created match data.
//    /// - Throws: Propagates errors from the data repository if the creation operation encounters issues.
//    func execute(request: Request) async throws -> Response {
//        
//        let iCloudStatus = iCloudService.shared.iCloudStatus
//        guard iCloudStatus == .available else {
//            return request
//        }
//        
//        return try recordRepository.create(matchRecord: request)
//    }
//}

