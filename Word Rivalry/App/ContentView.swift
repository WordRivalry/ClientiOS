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
    @State private var appState: AppState = .intro
    
    @State private var selection: AppScreen? = .home

    var body: some View {
        
        ZStack {
            Group {
                switch appState {
                    
                case .intro:
                    IntroView(onFinished: {
                        Task {
                            let profileExists = try await profile.exist()
                            appState = profileExists ? .home : .profileCreation
                        }
                    })
                    
                case .profileCreation:
                    ProfileCreationView(onProfileCreated: {
                        self.appState = .home
                    })
                    
                case .home:
                    AppTabView(selection: $selection)
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: appState)
        }
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
