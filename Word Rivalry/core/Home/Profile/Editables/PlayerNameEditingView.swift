//
//  PlayerNameEditingView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-06.
//

import SwiftUI

struct PlayerNameEditingView: View {
    @Environment(PublicProfile.self) private var profile: PublicProfile
    @Environment(\.dismiss) private var dismiss
    @State private var textField: String = "" // State for the text field input
    @State private var showingNameTakenAlert = false // For showing an alert if the name is taken
    @State private var showErrorAlert = false // For showing an error alert
    @State private var alertMessage = "" // Dynamic alert message

    var body: some View {
        VStack {
            Spacer()
            TextField("Enter new player name", text: $textField)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onAppear {
                    // Initialize the textField with the current playerName when the view appears
                    self.textField = self.profile.playerName
                }

            Button("Save") {
                save()
            }
            .padding()
            .alert(isPresented: $showingNameTakenAlert) {
                Alert(title: Text("Name Unavailable"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
            Spacer()
            BasicDismiss(text: "Cancel")
        }
        .padding()
    }

    func save() {
        Task {
            do {
                let newPlayerName = textField.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !newPlayerName.isEmpty else {
                    alertMessage = "Player name cannot be empty."
                    showErrorAlert = true
                    return
                }
                let isTaken: Bool = try await PublicDatabase.shared.isUsernameTaken(newPlayerName)
                if !isTaken {
                    let _ = try await PublicDatabase.shared.updatePlayerName(saving: newPlayerName)
                    DispatchQueue.main.async {
                        self.profile.playerName = newPlayerName
                        dismiss()
                    }
                } else {
                    alertMessage = "This username is already taken. Please choose another name."
                    showingNameTakenAlert = true
                }
            } catch {
                alertMessage = "An error occurred while updating the player name. Please try again."
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        PlayerNameEditingView()
            .environment(PublicProfile.preview)
    }
}
