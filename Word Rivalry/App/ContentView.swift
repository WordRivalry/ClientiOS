//
//  ContentView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-29.
//

import SwiftUI
import SwiftData
import CloudKit

enum AppState {
    case intro
    case home
}

@Observable final class iCloudService {
    static let shared = iCloudService()
    var iCloudStatus: CKAccountStatus?
    
    private init() {}
    
    func checkICloudStatus() {
        Task {
            self.iCloudStatus = try? await PublicDatabase.shared.iCloudAccountStatus()
        }
    }
}


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(Profile.local) var SD_profiles: [Profile]
    
    // Handle the entire color scheme of the app
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    
    // Handle app current displayed View
    @State private var contentViewState: AppState = .intro
    @State private var appScreen: AppScreen? = .home
    
    // User Flow
    @State private var transitionAfterIntro: AppState = .intro
    @State private var showNoInternet: Bool = false
    @State private var showUserFlowError: Bool = false
    
    var body: some View {
        Group {
            if iCloudService.shared.iCloudStatus == .available {
                Group {
                    switch contentViewState {
                    case .intro:
                        IntroView { contentViewState = transitionAfterIntro }
                    case .home:
                        AppTabView(selection: $appScreen)
                    }
                }
                .onAppear(perform: processUserFlow)
                .animation(.easeInOut, value: contentViewState)
                .transition(.opacity)
                .blurredOverlayWithAnimation(isPresented: $showNoInternet) {
                    InternetStatusMessageView(message: "For profile creation")
                }
                .blurredOverlayWithAnimation(isPresented: $showUserFlowError) {
                    InternetStatusMessageView(message: "User flow error")
                }
            
            } else {
                VStack {}
                    .blurredOverlayWithAnimation(isPresented: .constant(true)) {
                        IcloudStatusMessageView(status: iCloudService.shared.iCloudStatus)
                    }
            }
        }
            .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
    }
            
    func processUserFlow() {
        print("processUserFlow")
        if NetworkChecker.shared.isConnected {
            print("isConnected")
            do {
                try processWithInternet()
            } catch {
                print("User Flow Error Occured")
                withAnimation {
                    self.showUserFlowError = true
                }
            }
        } else {
            print("Not Connected")
            processWithoutInternet()
        }
    }
    
    private func processWithInternet() throws {
        print("processWithInternet")
        if let profile = SD_profiles.first {
            print("Swift Data found")
            useProfile(profile)
        } else {
            print("Swift Data not found")
            try fetchProfileFromNetwork()
        }
    }
    
    private func processWithoutInternet() {
        print("processWithoutInternet")
        if let profile = SD_profiles.first {
            print("Local Swift Data Found")
            useProfile(profile)
        } else {
            print("show No Internet")
            showNoInternet = true
        }
    }
    
    private func fetchProfileFromNetwork() throws {
        print("fetchProfileFromNetwork")
        Task {
            if let profile = try await PublicDatabase.shared.fetchProfileIfExist() {
                modelContext.insert(profile)
                print("profile exist and added to swift data")
                useProfile(profile)
                
            } else {
                print("profile doesnt exist")
                let profile = try await createProfile()
                useProfile(profile)
            }
        }
    }
    
    private func createProfile() async throws -> Profile {
        print("createProfile")
        // Public profile
        let profile = try await PublicDatabase.shared.addProfileRecord(playerName: UUID().uuidString)
        
        // SwiftData profile
        modelContext.insert(profile)
        
        return profile
    }
    
    private func useProfile(_ profile: Profile) {
        LocalProfile.shared.setProfile(profile: profile)
        transitionAfterIntro = .home
        print("profile used")
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

struct IcloudStatusMessageView: View {
    let status: CKAccountStatus?
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.icloud")
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text("iCloud Status")
                .font(.headline)
                .padding(.top, 2)
            Text(
                statusMessage()
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
    
    private func statusMessage() -> String {
        switch status {
        case .available:
            return "Available"
        case .couldNotDetermine:
            return "Could not determine"
        case .noAccount:
            return "No account"
        case .restricted:
            return "Restricted"
        case .temporarilyUnavailable:
            return "Temporarily unavailable"
        case .none:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
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
        ContentView()
            .modelContainer(previewContainer)
    }
}
