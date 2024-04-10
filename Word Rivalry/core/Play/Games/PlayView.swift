//
//  GamesView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI

struct PlayView: View {
    @Environment(PublicProfile.self) private var profile: PublicProfile
    @State private var showCover = false
    @State private var selectedType: ModeType = .NORMAL
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Divider()
                ForEach(ModeType.allCases, id: \.self) { type in
                    GameCardView(cardName: type.rawValue) {
                        self.selectedType = type
                        self.showCover = true
                        SearchService.shared.searchMatch(
                            modeType: type,
                            playerName: profile.playerName,
                            playerUUID: profile.userRecordID,
                            eloRating: profile.eloRating
                        )
                    }
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showCover) {
            BattleOrchestratorView(profile: profile, modeType: selectedType)
                .presentationBackground(.bar)
                .fadeIn()
        }
    }
}

#Preview {
    PlayView()
}
