//
//  SystemTimeProvider.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-04.
//

import Foundation

/// Provides the current date and time, allowing for easier testing and decoupling from system time.
protocol TimeProviding {
    /// Returns the current date.
    func currentDate() -> Date
}

/// Provides the system's current date and time. Default time provider used in production.
struct SystemTimeProvider: TimeProviding {
    /// Retrieves the current system date.
    func currentDate() -> Date {
        return Date()
    }
}
