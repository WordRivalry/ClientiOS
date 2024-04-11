//
//  LifeCycleProtocols.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation

protocol SceneLifeCycle {
    func handleAppBecomingActive() -> Void
    func handleAppGoingInactive() -> Void
    func handleAppInBackground() -> Void
}

protocol ViewLifeCycle {
    func handleViewDidAppear() -> Void
    func handleViewDidDisappear() -> Void
}
