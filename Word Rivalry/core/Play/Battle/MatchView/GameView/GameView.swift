//
//  GameView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI
import os.log

struct GameView: View {
    @State var opponentProfile: PublicProfile
    private var gameModel: GameModel
    @State private var showingQuitAlert = false
    @Environment(\.dismiss) var dismiss
    @Environment(PublicProfile.self) private var profile: PublicProfile
    @Environment(InGameDisplaySettings.self) private var inGameDisplay
    
    private let logger = Logger(subsystem: "com.WordRivalry", category: "GameView")
    
    init(gameModel: GameModel, opponentProfile: PublicProfile) {
        self.gameModel = gameModel
        self.opponentProfile = opponentProfile
        self.logger.debug("*** GameView INITIATED ***")
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    PortraitView(
                        profileImage: profile.profileImage,
                        banner: profile.banner
                    )
                    .scaleEffect(0.4)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                  //  PlayerNameView(playerName: profile.playerName)
                    Text("Score: \(gameModel.currentScore)")
                    
                }
                Spacer()
                Spacer()
                VStack {
                    PortraitView(profileImage: opponentProfile.profileImage, banner: opponentProfile.banner)
                        .scaleEffect(0.4)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    
                    PlayerNameView(playerName: gameModel.opponentName)
                    
                    if inGameDisplay.showOpponentScore {
                        Text("Score: \(gameModel.opponentScore)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            Spacer()
            // Displaying dynamic content
            VStack(alignment: .center, spacing: 10) {
                Text("\(gameModel.timeLeft)")
                    .font(.title)
            }
           
            Spacer()
            HStack {
                if inGameDisplay.showOpponentScore {
                    Text("Path: \(gameModel.currentPathScore)")
                        .padding(.horizontal)
                    Spacer()
                }
             
                
                Text("\(gameModel.currentScore - gameModel.opponentScore)")
                Spacer()
                
                if inGameDisplay.showMessage {
                    Text("\(gameModel.message)")
                        .padding(.horizontal)
                }
            }
            LetterBoardView(viewModel: gameModel)
                .cornerRadius(10)
                .scaleEffect(0.9)
                .frame(maxWidth: .infinity, maxHeight: 400)
            
            Spacer()
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
            self.logger.debug("* GameView Appeared *")
            gameModel.startGame()
            
            self.logger.debug("Deducted 10 Elo Points *")
            Task {
                let val = profile.eloRating - 10
                try await PublicDatabase.shared.updatePlayerEloRating(saving: val)
            }
        //    profile.eloRating -= 10
        }.onDisappear {
            self.logger.debug("* GameView Disappeared *")
            
            if gameModel.gameResults.winner == profile.playerName {
                self.logger.debug("Reawrded 10 Elo Points *")
          //      profile.eloRating += 20
                Task {
                    let val = profile.eloRating + 10
                    try await  PublicDatabase.shared.updatePlayerEloRating(saving: val)
                }
            }
        }
    }
}

#Preview {
    let gameModel = GameModel()
    gameModel.board = Board(
            rows: 4,
            cols: 4,
            initialValue: LetterTile(
                letter: "A",
                value: 1,
                letterMultiplier: 1,
                wordMultiplier: 1)
    )
    
    gameModel.opponentName = "Player 1"
    gameModel.opponentScore = 20
    gameModel.timeLeft = "10"
    gameModel.message = "Message field"
    
    return ViewPreview {
        GameView(gameModel: gameModel, opponentProfile: PublicProfile.preview)
    }
}
