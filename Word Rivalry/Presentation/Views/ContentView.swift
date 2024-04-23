//
//  ContentView2.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI
import OSLog

struct ContentView: View {
    @Environment(AppServiceManager.self) private var appService
    
    init() {
        Logger.viewCycle.debug("~~~ ContentView init ~~~")
    }
    
    var body: some View {
        Group {
            switch StartUpViewModel.shared.screen {
            case .loading:
                loadingView
            case .mainContent:
                MainContentView()
            }
        }
        .onAppear {
            Task {
                Logger.serviceManager.debug("Attempting to start app services.")
                _ = await self.appService.start()
            }
        }
        .overlay {
            GlobalOverlayView()
        }
     
        .logLifecycle(viewName: "ContentView")
    }
    
    
    @ViewBuilder
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView(value: appService.progressReporter.progress, total: 100)
            Text(appService.messages.last ?? "Nothing to worry!")
            Spacer()
        }
        .frame(width: 350)
        .transition(.opacity)
    }
}

#Preview {
    ViewPreview {
        ContentView()
            .environment(
                AppServiceManager(
                    audioService: AudioSessionService()
                )
            )
    }
}
