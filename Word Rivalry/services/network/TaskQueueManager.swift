//
//  TaskQueueManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import Foundation

class TaskQueueManager {
    static let shared = TaskQueueManager()
    
    private var tasks = [() -> Void]()
    private let queue = DispatchQueue(label: "com.yourapp.taskQueueManager", attributes: .concurrent)
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(executeQueuedTasks), name: .didConnectToInternet, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func queueTask(_ task: @escaping () -> Void) {
        queue.async(flags: .barrier) {
            self.tasks.append(task)
        }
    }
    
    @objc private func executeQueuedTasks() {
        queue.async(flags: .barrier) {
            self.tasks.forEach { $0() }
            self.tasks.removeAll()
        }
    }
}
