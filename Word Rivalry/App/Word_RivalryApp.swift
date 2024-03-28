//
//  Word_RivalryApp.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-29.
//

import SwiftUI
import SwiftData

@main
struct Word_RivalryApp: App {
    
    let appService = AppService()
    
    init() {
        appService.startApplication()
    }
    
    var body: some Scene {
        let services = appService.services
        WindowGroup {
            ContentView()
                .environmentObject(services.audioService)
                .environmentObject(services.themeService)
                .modelContainer(for: Profile.self)
        }
    }
}
