//
//  Cacheable.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

protocol Cacheable {
    associatedtype CacheType
    func get(forKey key: String) -> CacheType?
    func set(_ object: CacheType, forKey key: String)
    func remove(forKey key: String)
}
