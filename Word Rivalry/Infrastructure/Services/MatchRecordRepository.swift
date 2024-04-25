//
//  MatchRecordRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-24.
//

import Foundation
import OSLog

enum MatchRecordRepositoryError: Error {
    case dataSourceNotSet
}

final class MatchRecordRepository: MatchRecordRepositoryProtocol {

    private var dataSource: SwiftDataSource
 
    init(dataSource: SwiftDataSource) {
        self.dataSource = dataSource
    }
    
    func fetch() throws -> [MatchRecord]   {
        return dataSource.fetch(type: MatchRecord.self)
    }
    
    func create(matchRecord: MatchRecord) throws -> MatchRecord {
        dataSource.append(matchRecord)
        return matchRecord
    }
    
    func save() throws {
        dataSource.save()
    }

    func delete(matchRecord: MatchRecord) async throws {
        dataSource.remove(matchRecord)
    }
}
