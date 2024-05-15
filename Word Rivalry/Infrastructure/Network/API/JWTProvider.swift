//
//  JWTProvider.swift
//  DemoApp
//
//  Created by benoit barbier on 2024-05-14.
//

import Foundation
import JWTKit
import CryptoKit
import CommonCrypto
import OSLog

class JWTProvider {
 
    func generateAndEncryptJWT(userID: String, privateKey: String) throws -> String {
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let nonce = UUID().uuidString
        let exp = ExpirationClaim(value: Date().addingTimeInterval(300)) // 5 minutes expiration
        
        let claims = MyClaims(userID: userID, exp: exp, timestamp: timestamp, nonce: nonce)
        
        Logger.dataServices.debug("Signing JWT with claims: \(claims.userID)")
        
        let signer = JWTSigner.hs256(key: Data(privateKey.utf8))
        let jwt = try signer.sign(claims)
        Logger.dataServices.debug("Generated JWT: \(jwt)")
        
        // Encrypt the JWT payload
        let keyData = Data("12345678901234567890123456789012".utf8)
        let key = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.seal(Data(jwt.utf8), using: key)
        Logger.dataServices.debug("Sealed Box: \(sealedBox.ciphertext.debugDescription)")

        // Convert sealedBox to a base64 string to send as a JWE
        let encryptedJWT = sealedBox.combined?.base64EncodedString() ?? ""
        Logger.dataServices.debug("Encrypted JWT (JWE): \(encryptedJWT)")
        
        return encryptedJWT
    }
    
    // Generate a JWT
    func generateJWT(userID: String, privateKey: String) throws -> String {
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let nonce = UUID().uuidString
        let exp = ExpirationClaim(value: Date().addingTimeInterval(300)) // 5 minutes expiration
        
        let claims = MyClaims(userID: userID, exp: exp, timestamp: timestamp, nonce: nonce)
        let signer = JWTSigner.hs256(key: Data(privateKey.utf8))
        
        return try signer.sign(claims)
    }
}

struct MyClaims: JWTPayload {
    var userID: String
    var exp: ExpirationClaim
    var timestamp: String
    var nonce: String

    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}
