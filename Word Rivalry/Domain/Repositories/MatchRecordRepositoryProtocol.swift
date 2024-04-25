//
//  MatchRecordRepositoryProtocol.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-24.
//

import Foundation

protocol MatchRecordRepositoryProtocol {
    func fetch() async throws -> [MatchRecord]
    func create(matchRecord: MatchRecord) async throws -> MatchRecord
    func save() async throws -> Void
    func delete(matchRecord: MatchRecord) async throws -> Void
}
