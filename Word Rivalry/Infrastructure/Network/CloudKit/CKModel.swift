//
//  CloudKitConvertible.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-14.
//

import Foundation
import CloudKit

protocol CKModel: Codable {
    static var recordType: String { get }
    var record: CKRecord { get }
    var recordName: String { get }
    var zoneName: String { get }
    init?(from ckRecord: CKRecord)
    
    // Define key handling
    associatedtype Key: CaseIterable, RawRepresentable where Key.RawValue == String
    
    // Function to get the string value for a given key (already defined via RawRepresentable conformance)
    static func forKey(_ key: Key) -> String
}

extension CKModel {
    // Helper to convert enum Key to String for CKRecord
    static func forKey(_ key: Key) -> String {
        return key.rawValue
    }
}
