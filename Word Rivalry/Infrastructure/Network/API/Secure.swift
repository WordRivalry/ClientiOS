//
//  Secure.swift
//  DemoApp
//
//  Created by benoit barbier on 2024-05-13.
//

import CloudKit
import Foundation
import CommonCrypto

class RequestSecurityApplicator {
    private let jwtProvider: JWTProvider
    private let hmacGenerator: HMACGenerator

    init(jwtProvider: JWTProvider, hmacGenerator: HMACGenerator) {
        self.jwtProvider = jwtProvider
        self.hmacGenerator = hmacGenerator
    }

    func applySecurity(to urlRequest: inout URLRequest, userID: String) async throws {
        let privateKey = "development"
        let encryptedJWT = try jwtProvider.generateAndEncryptJWT(userID: userID, privateKey: privateKey)
        urlRequest.setValue("Bearer \(encryptedJWT)", forHTTPHeaderField: "Authorization")
    }
}

enum SecurityError: Error {
    case hmacGenerationFailed
    case invalidURL
}
