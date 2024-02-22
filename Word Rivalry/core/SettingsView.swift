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
    
    var body: some View {
        NavigationView {
            List {
                Section{
                    Toggle(isOn: $hapticFeedbackEnabled) {
                        Text("Haptic Feedback")
                    }
               
   
                
                    Picker("Appearance", selection: $colorSchemeManager.selectedColorScheme) {
                        Text("Dark").tag("dark")
                        Text("Light").tag("light")
                        Text("System").tag("system")
                    }
                    .pickerStyle(.navigationLink)
                    .listRowSeparator(.hidden)
                }
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
                .listRowSeparator(.hidden)
            }
            /// List Modifiers
            .listStyle(.automatic)
            .environment(\.defaultMinListRowHeight, 70)
            .scrollContentBackground(.hidden)
            
            /// View Modifiers
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
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
