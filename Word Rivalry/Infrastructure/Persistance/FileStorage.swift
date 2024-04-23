//
//  CoreDataCache.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation
import CoreData

class FileStorage<T: Codable> {
    private let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    private func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent(fileName)
    }

    func load() async throws -> T {
        let data = try Data(contentsOf: fileURL())
        return try JSONDecoder().decode(T.self, from: data)
    }

    func save(data: T) async throws {
        let data = try JSONEncoder().encode(data)
        let url = try fileURL()
        try data.write(to: url, options: .atomicWrite)
    }
    
    func invalidate() throws {
        let url = try fileURL()
        try FileManager.default.removeItem(at: url)
    }
}
