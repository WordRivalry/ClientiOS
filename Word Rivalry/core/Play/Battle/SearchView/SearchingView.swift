//
//  SearchView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI
import OSLog

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the search view events from the app
    static let searchView = Logger(subsystem: subsystem, category: "searchView")
}

struct SearchingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(BattleOrchestrator.self) private var battleOrchestrator: BattleOrchestrator
    
    init() {
        debugPrint("~~~ SearchingView init ~~~")
    }
    
    var body: some View {
        ZStack {
            AnimatedCirclesView()
            
            VStack {
                
                Text(battleOrchestrator.modeType.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                
                Spacer()
                
                Text("Searching")
                    .foregroundColor(.primary)
                    .font(.title2)
                    .padding()
                    .shadow(radius: 10)
                    .blinkingEffect()
                
                Spacer()
                
                BasicDismiss(text: "Cancel") {
                    do {
                        try SearchService.shared.cancelSearch()
                        Logger.searchView.debug("SearchView Dismissed")
                    } catch {
                        Logger.searchView.error("Error occurred: \(error)")
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .handleNetworkChanges(onDisconnect: {
            Logger.searchView.debug("SearchView Dismissed")
            try? SearchService.shared.cancelSearch()
            dismiss()
        })
        .logLifecycle(viewName: "SearchingView")
    }
}

#Preview {
    ViewPreview {
        SearchingView()
    }
}
