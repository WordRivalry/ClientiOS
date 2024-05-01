//
//  Cache.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import Foundation

@dynamicMemberLookup
@dynamicCallable
final class NamesCache {
    private var names: [String] = []

    subscript<T>(dynamicMember keyPath: KeyPath<[String], T>) -> T {
        return names[keyPath: keyPath]
    }

    @discardableResult
    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, String>) -> Bool {
        for (key, value) in args {
            if key == "contains" {
                return names.contains(value)
            } else if key == "store" {
                names.append(value)
                return true
            }
        }
        return false
    }
}
