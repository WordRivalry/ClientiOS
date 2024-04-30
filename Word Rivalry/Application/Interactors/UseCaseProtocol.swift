//
//  UseCaseProtocol.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

protocol UseCaseProtocol {
    /// `Request` represents the type of data that this use case expects to receive to perform its operation.
    associatedtype Request
    /// `Response` represents the type of data that this use case returns upon completion.
    associatedtype Response
    func execute(request: Request) async throws -> Response
}
