//
//  GameView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct GameView: View {
    private var gameModel: GameModel
    @State private var showingQuitAlert = false
    @Environment(\.dismiss) var dismiss
    @Environment(Profile.self) private var profile: Profile
    
    
    @State private var opponentProfile: Profile?

    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }

    var body: some View {
        VStack {
            
            HStack {
                VStack {
                    PortraitView(
                        profileImage: profile.profileImage,
                        banner: profile.banner
                    )
                    .scaleEffect(0.5)
                    Text(profile.playerName)
                    
                    Text("Score: \(gameModel.currentScore)")
                }
                Spacer()
                VStack {
                    if let opponentProfile = opponentProfile {
                        PortraitView(
                            profileImage: opponentProfile.profileImage,
                            banner: opponentProfile.banner
                        )
                    }
                    Text(gameModel.opponentName)
                    Text("Score: \(gameModel.opponentScore)")
                }
          
            }
            
            // Displaying dynamic content
            VStack(alignment: .leading, spacing: 10) {
                Text("\(gameModel.timeLeft)")
                Text("\(gameModel.message)")
            }
            HStack {
                Text("Path: \(gameModel.currentPathScore)")
                    .padding(.horizontal)
                Spacer()
            }
         
            Spacer()
        
            LetterBoardView(viewModel: gameModel)
                .cornerRadius(10)
                .scaleEffect(0.8)
            
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
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to forfeit the match?")
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            gameModel.startGame()
            Task {
                opponentProfile = try await PublicDatabase.shared.fetchProfile(forPlayerName: gameModel.opponentName)
            }
        }
    }
}
#Preview {
    GameView(gameModel: GameModel())
        .environment(Profile.preview)
}
