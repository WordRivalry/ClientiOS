//
//  AppServiceProtocol.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation

protocol AppService: AnyObject, SceneLifeCycle {
    var isReady: Bool { get }
    var isCritical: Bool { get }
    
    /// This method must not fail.
    /// It can either succeed and mark the flag as ready, or do nothing.
    /// Return a message to be displayed to the user.
    func start() async -> String
}
