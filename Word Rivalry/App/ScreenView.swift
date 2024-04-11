//
//  ContentView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-29.
//

import SwiftUI
import SwiftData
import CloudKit
import os.log

enum AppState {
    case intro
    case home
}

struct ScreenView: View {
    private let logger = Logger(subsystem: "com.WordRivalry", category: "ContentView")
    
    // For setting environnement
    @Environment(LaunchService.self) private var launchService: LaunchService
    var ppService = PPLocalService.shared
    // Handle the entire color scheme of the app
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    
    // Handle app current displayed View
    @State private var contentViewState: AppState = .intro
    @State private var appScreen: AppScreen? = .home
    
    // User Flow
    @State private var transitionAfterIntro: AppState = .intro
    
    init() {
        self.logger.debug("*** AppService ContentView ***")
    }
    
    var body: some View {
        Group {
            switch launchService.screenToPresent {
            case .intro:
                Text("Loading...")
            case .noIcloud:
                IcloudStatusMessageView()
            case .noInternet:
                InternetStatusMessageView(message: "For profile creation")
            case .home:
                AppTabView(selection: $appScreen)
                    .environment(ppService.player!)
                    .environment(launchService.profile)
                    .environment(launchService.achievementsProgression)
                    .environment(launchService.leaderboard)
                    .environment(launchService.friends)
            case .error:
                Text("An error occured")
            }
        }
        .animation(.easeInOut, value: contentViewState)
        .transition(.opacity)
        .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
    }
}

struct IcloudStatusMessageView: View {
    let status: String = iCloudService.shared.statusMessage()
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.icloud")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("iCloud Status")
                .font(.headline)
                .padding(.top, 2)
            Text(
                status
            )
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding()
        }
        .padding()
        .background(.clear)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

struct InternetStatusMessageView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("Internet Connection Required")
                .font(.headline)
                .padding(.top, 2)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(.clear)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }
}

#Preview {
    MainActor.assumeIsolated {
        ScreenView()
            .environment(LaunchService(dataService: SwiftDataService()))
    }
}
