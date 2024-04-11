//
//  SettingsView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    @State private var hapticFeedbackEnabled = true
    @State private var pathScoreEnabled = true
    @State private var opponentScoreEnabled = true
    @State private var gameCenterAccessEnabled = true
    @State private var gameCenterFriendNotification = true
    @State private var musicVolume: Double = 0
    @State private var sfxVolume: Double = 0
    
    
    // Simple feedback mechanism
    private func provideFeedback() {
        if hapticFeedbackEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                Section(header: Text("Game Center - Display")) {
                    Toggle(isOn: $gameCenterAccessEnabled) {
                        Text("Access point")
                    }
                    .tint(.accent)
                    
                    Toggle(isOn: $gameCenterFriendNotification) {
                        Text("Friend Notification")
                    }
                    .tint(.accent)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.bar)
                )
                
                Section(header: Text("In Game - Display")) {
                    Toggle(isOn: $pathScoreEnabled) {
                        Text("Path score")
                    }
                    .tint(.accent)
                    
                    Toggle(isOn: $opponentScoreEnabled) {
                        Text("Opponent score")
                    }
                    .tint(.accent)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.bar)
                )
                
                Section(header: Text("Sound")) {
                    VStack {
                        Slider(value: $musicVolume, in: 0...100) {
                            Text("Music Volume")
                        } minimumValueLabel: {
                            Image(systemName: "")
                        } maximumValueLabel: {
                            Image(systemName: (musicVolume == 0) ? "speaker.slash" :  (musicVolume <= 33) ? "speaker.wave.1" : (musicVolume <= 66) ? "speaker.wave.2" : "speaker.wave.3"
                            )
                        }
                        .onChange(of: musicVolume) {
                            provideFeedback()
                        }
                        Text("Music Volume: \(Int(musicVolume))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Slider(value: $sfxVolume, in: 0...100) {
                            Text("SFX Volume")
                        } minimumValueLabel: {
                            Image(systemName: "")
                        } maximumValueLabel: {
                            Image(systemName: (sfxVolume == 0) ? "speaker.slash" :  (sfxVolume <= 33) ? "speaker.wave.1" : (sfxVolume <= 66) ? "speaker.wave.2" : "speaker.wave.3"
                            )
                        }
                        .onChange(of: sfxVolume) {
                            provideFeedback()
                        }
                        Text("SFX Volume: \(Int(sfxVolume))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tint(.accent)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.bar)
                )
                
                Section(header: Text("Appearance and behavior")) {
                    Picker("Appearance", selection: $colorSchemeManager.selectedColorScheme) {
                        Text("Dark").tag("dark")
                        Text("Light").tag("light")
                        Text("System").tag("system")
                    }
                    .pickerStyle(.navigationLink)
                    
                    Toggle(isOn: $hapticFeedbackEnabled) {
                        Text("Haptic Feedback")
                    }
                    .tint(.accent)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.bar)
                )
                
                Section {
                    NavigationLink(destination: TermsOfServiceView()) {
                        Text("Terms of Service")
                    }
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                    }
                    
                    Button("Send Feedback") {
                        // TODO: Implement feedback functionality
                    }
                    
                    Button("Help & Support") {
                        // TODO: Link to support resources
                    }
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.bar)
                )
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.gray)
                    }
                    NavigationLink(destination: LicensesView()) {
                        Text("Licenses")
                    }
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.bar)
                )
                .listRowSeparator(.hidden)
            }
            /// List Modifiers
            .listStyle(.automatic)
            .environment(\.defaultMinListRowHeight, 50)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            
            /// View Modifiers
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background( Image("bg")
                .resizable()
                .ignoresSafeArea())
            .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
        }
    }
}

struct LicensesView: View {
    var body: some View {
        Text("All licenses information goes here.")
            .padding()
            .navigationTitle("Licenses")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        Text("All licenses information goes here.")
            .padding()
            .navigationTitle("Terms of Service")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        Text("All Privacy Policy information goes here.")
            .padding()
            .navigationTitle("Privacy Policy")
    }
}

#Preview {
    SettingsView()
}
