//
//  ForfeitButtonView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-20.
//

import SwiftUI

struct ForfeitButtonView: View {
    @State var showingQuitAlert = false
    @Environment(GameViewModel.self) private var gameModel
    
    var body: some View {
        Button {
            showingQuitAlert = true
        } label: {
            Text("Quit")
        }
        .alert("Forfeit Match?", isPresented: $showingQuitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Forfeit", role: .destructive) {
                gameModel.quitGame()
                BattleServerService.shared.leaveGame()
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
