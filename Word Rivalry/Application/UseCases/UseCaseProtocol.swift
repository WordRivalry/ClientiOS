//
//  UseCaseProtocol.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

protocol UseCaseProtocol {
    associatedtype Request
    associatedtype Response
    func execute(request: Request) async throws -> Response
}
