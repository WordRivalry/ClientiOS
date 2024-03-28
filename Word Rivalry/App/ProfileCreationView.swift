//
//  CreateProfileView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import SwiftUI

struct ProfileCreationView: View {
    @Environment(\.modelContext) private var modelContext
    var onProfileCreated: (_ profile: Profile) -> Void
    @State private var playerNameTextField: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 20) { // Increased spacing for better element separation
            Text("Create Your Profile")
                .font(.largeTitle) // Enhancing title visibility
                .fontWeight(.bold) // Making title bold for emphasis
                .padding(.bottom, 20) // Additional padding to separate title from text field
            
            TextField("Enter Username", text: $playerNameTextField)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color(.systemGray6)) // Adding a background color for better contrast
                .cornerRadius(10) // Rounded corners for modern appearance
                .padding(.horizontal) // Ensuring padding is applied on both sides
            
            Button(action: {
                Task {
                    await createProfile()
                }
            }) {
                Text("Create Profile")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity) // Button width extends to max available space
                    .padding()
                    .foregroundColor(.white) // White text for better contrast
                    .background(playerNameTextField.isEmpty ? Color.gray : Color.blue) // Dynamic background color
                    .cornerRadius(10) // Rounded corners for button
            }
            .disabled(playerNameTextField.isEmpty) // Disabling button when username is empty
            
            Spacer()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensuring view takes full available space
        .background(Color(.systemGray5).edgesIgnoringSafeArea(.all)) // Setting a background color for the entire view
    }
    
    private func createProfile() async {
        do {
            // Public profile
            let profile = try await PublicDatabase.shared.addProfileRecord(playerName: playerNameTextField)
            
            // Private profile
            self.createProfile(profile)
  
            // Callback
            onProfileCreated(profile)
        } catch {
            errorMessage = "Failed to create profile: \(error.localizedDescription)"
        }
    }
    
    private func createProfile(_ profile: Profile) {
        modelContext.insert(profile)
    }
}

#Preview {
    ProfileCreationView(onProfileCreated: {profile in })
}
