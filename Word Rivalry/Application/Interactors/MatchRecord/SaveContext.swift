//
//  SaveContext.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-24.
//

import Foundation


///// A use case class for saving match records via SwiftData.
///// This class adheres to the `UseCaseProtocol`, specifying its core functionality for persisting match records data.
//final class SaveContext: UseCaseProtocol {
//    /// The `Request` type is unused in this case, as the save operation does not require external input parameters.
//    typealias Request = Void
//    
//    /// The `Response` type is also `Void`, indicating that this use case does not return a result but may throw errors on failure.
//    typealias Response = Void
//    
//    /// Repository for handling data operations related to match records. It uses a `SwiftDataSource` for data handling.
//    @MainActor
//    let recordRepository = MatchRecordRepository(dataSource: SwiftDataSource.shared)
//    
//    /// Executes the operation to save changes in the context of match records.
//    /// - Parameter request: Unused in this method.
//    /// - Throws: Propagates errors from the data repository if the save operation encounters issues.
//    func execute(request: Request = ()) async throws -> Response {
//        
//        let iCloudStatus = iCloudService.shared.iCloudStatus
//        guard iCloudStatus == .available else {
//            return
//        }
//        
//        // Perform the save operation using the match record repository.
//        try recordRepository.save()
//    }
//}

