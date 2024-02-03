//
//  SettingsView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

struct SettingsView: View {
    @State private var hapticFeedbackEnabled = true
    @State private var appearanceSetting = "System"
    let appearanceOptions = ["Light", "Dark", "System"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")) {
               
                    
                    Picker("Appearance", selection: $appearanceSetting) {
                        ForEach(appearanceOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Toggle(isOn: $hapticFeedbackEnabled) {
                        Text("Haptic Feedback")
                    }
                }
                
                Section(header: Text("Privacy & Security")) {
                                  NavigationLink(destination: TermsOfServiceView()) {
                                      Text("Terms of Service")
                                  }
                                  NavigationLink(destination: PrivacyPolicyView()) {
                                      Text("Privacy Policy")
                                  }
                              }
                              
                              Section(header: Text("Feedback & Support")) {
                                  Button("Send Feedback") {
                                      // TODO: Implement feedback functionality
                                  }
                                  
                                  Button("Help & Support") {
                                      // TODO: Link to support resources
                                  }
                              }
                              
                              Section(header: Text("About")) {
                                  HStack {
                                      Text("Version")
                                      Spacer()
                                      Text("1.0.0").foregroundColor(.gray)
                                  }
                                  NavigationLink(destination: LicensesView()) {
                                      Text("Licenses")
                                  }
                              }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
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
