//
//  ContentView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-29.
//

import SwiftUI
import SwiftData

enum AppState {
    case intro
    case profileCreation
    case home
}

struct ContentView: View {
    @EnvironmentObject var profile: ProfileService
    
    // Handle the entire color scheme of the app
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    
    // Handle app current displayed View
    @State private var contentViewState: AppState = .home
    @State private var appScreen: AppScreen? = .home
    
    init() {
    }
    
    var body: some View {
        
        ZStack {
            Group {
                switch contentViewState {
                case .intro:
                    IntroView(onFinished: {
                        Task {
                            /// If no profil, show profil creation window
                            let profileExists = try await profile.exist()
                            contentViewState = profileExists ? .home : .profileCreation
                        }
                    })
                    
                case .profileCreation:
                    ProfileCreationView(onProfileCreated: {
                        self.contentViewState = .home
                    })
                    
                case .home:
                    AppTabView(selection: $appScreen)
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: contentViewState)
        }
        .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
  
        
    }
}


struct LoadingView: View {
    var body: some View {
        ProgressView("Loading...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5)) // Semi-transparent overlay
            .foregroundColor(.white)
    }
}

struct InternetConnectionRequiredView: View {
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash") // An icon indicating no internet connection
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
            Text("Internet Connection Required")
                .foregroundColor(.white)
                .font(.headline)
            Text("Please check your internet connection to continue.")
                .foregroundColor(.white)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5)) // Semi-transparent overlay
        .edgesIgnoringSafeArea(.all) // Cover the entire screen
    }
}



#Preview {
    ContentView()
        .environmentObject(ProfileService())
}
