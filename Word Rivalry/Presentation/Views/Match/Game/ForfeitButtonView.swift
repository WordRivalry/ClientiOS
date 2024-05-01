//
//  ForfeitButtonView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-20.
//

import SwiftUI

struct ForfeitButtonView: View {
    @State var showingQuitAlert = false
    @Environment(SoloGameViewModel.self) private var gameViewModel
    @Environment(MainRouter.self) private var mainRouter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            showingQuitAlert = true
        } label: {
            Text("Quit")
        }
        .alert("Forfeit Match?", isPresented: $showingQuitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Forfeit", role: .destructive) {
                Task {
                    do {
                        try await gameViewModel.forfeit()
                    } catch {
                        dismiss()
                    }
                 
                }
            }
        } message: {
            Text("Are you sure you want to forfeit the match?")
        }
    }
}

#Preview {
    ViewPreview {
        ForfeitButtonView()
    }
}
