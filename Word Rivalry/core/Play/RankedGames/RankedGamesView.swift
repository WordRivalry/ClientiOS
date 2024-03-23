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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Divider()
                    ForEach(ModeType.allCases, id: \.self) { type in
                        RankedGameCardView(cardName: type.rawValue) {
                            self.viewModel.searchMatch(modeType: type)
                        }
                    }
                    
                    RankedGameTournamentCardView(nextTournament: viewModel.nextTournament)
                }
                .padding()
            }
            .navigationTitle("Ranked")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $viewModel.showingCover) {
                FullScreenCoverView(
                    gameMode: self.viewModel.activeGameMode,
                    modeType: self.viewModel.activeModeType
                )
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
    RankedGamesView()
}
