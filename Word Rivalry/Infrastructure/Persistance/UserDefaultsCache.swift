//
//  UserDefaultsCache.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

class UserDefaultsCache<T: Codable>: Cacheable {
    func get(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func set(_ object: T, forKey key: String) {
        let data = try? JSONEncoder().encode(object)
        UserDefaults.standard.set(data, forKey: key)
    }

    func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
