//
//  HMACGenerator.swift
//  DemoApp
//
//  Created by benoit barbier on 2024-05-14.
//

import Foundation
import CommonCrypto

class HMACGenerator {
    private let secretKey: String

    init(secretKey: String) {
        self.secretKey = secretKey
    }

    func generateHMAC(message: String) -> String? {
        let keyData = secretKey.data(using: .utf8)!
        let messageData = message.data(using: .utf8)!
        var hmacData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        hmacData.withUnsafeMutableBytes { hmacBytes in
            messageData.withUnsafeBytes { messageBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes.baseAddress, keyData.count, messageBytes.baseAddress, messageData.count, hmacBytes.baseAddress)
                }
            }
        }
        
        return hmacData.base64EncodedString()
    }
}
