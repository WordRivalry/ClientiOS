//
//  BackgroundTaskManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()

    private init() {} // Private initialization to ensure singleton instance

    func performBackgroundTask(task: @escaping () async -> Void, completion: @escaping () -> Void) {
        Task {
            await task()  // Perform the background task

            await MainActor.run {
                completion()  // Update the UI on the main thread
            }
        }
    }
}
