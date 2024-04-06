//
//  RankedMatchmaking.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct RankedGamesView: View {
    @Bindable private var viewModel = RankedGamesModel()
    @State private var showDetailsForCard: ModeType?
    @Environment(Profile.self) private var profile: Profile

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Divider()
                    ForEach(ModeType.allCases, id: \.self) { type in
                        RankedGameCardView(cardName: type.rawValue) {
                            self.viewModel.searchMatch(
                                modeType: type,
                                playerName: profile.playerName,
                                playerUUID: profile.userRecordID
                            )
                        }
                    }
//                    
//                    RankedGameTournamentCardView(nextTournament: viewModel.nextTournament)
                }
                .padding()
            }
            .fullScreenCover(isPresented: $viewModel.showingCover) {
                FullScreenCoverView(
                    searchModel: SearchModel(modeType: self.viewModel.activeModeType, playerName: profile.playerName, playerUUID: profile.userRecordID)
                )
                .presentationBackground(.bar)
                .fadeIn()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        RankedGamesView()
            .environment(Profile.preview)
    }
}
