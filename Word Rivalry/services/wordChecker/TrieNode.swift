//
//  TrieNode.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import Foundation

class TrieNode: Codable {
    var children: [String: TrieNode] = [:]
    // Directly store isEndOfWord as a Bool rather than computing from children keys
    var isEndOfWord: Bool = false

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        for key in container.allKeys {
            // Check for the "*" marker to set isEndOfWord
            if key.stringValue == "*" {
                // If "*" is present, this node represents the end of a word
                isEndOfWord = true
            } else {
                // Decode child nodes as TrieNode
                let value = try container.decode(TrieNode.self, forKey: key)
                children[key.stringValue] = value
            }
        }
    }

    // Encode function remains unchanged
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        // Encode children nodes
        for (key, value) in children {
            try container.encode(value, forKey: DynamicCodingKeys(stringValue: key)!)
        }
        // Encode isEndOfWord by adding "*" marker if true
        if isEndOfWord {
            try container.encodeNil(forKey: DynamicCodingKeys(stringValue: "*")!)
        }
    }

    // DynamicCodingKeys struct remains unchanged
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
}
