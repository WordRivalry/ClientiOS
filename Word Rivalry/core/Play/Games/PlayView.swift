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
    
    init() {
        debugPrint("~~~ PlayView init ~~~")
    }
    
    var body: some View {
        
            VStack(spacing: 20) {
                Divider()
                GameCardView(cardName: ModeType.NORMAL.rawValue) {
                    self.selectedType = ModeType.NORMAL
                    self.showCover = true
                    SearchService.shared.searchMatch(
                        modeType: ModeType.NORMAL,
                        playerName: profile.playerName,
                        playerUUID: profile.userRecordID,
                        eloRating: profile.eloRating
                    )
                }
                Spacer()
                MatchesHistoricView()
       
                .frame(height: 500)
            }
            .fullScreenCover(isPresented: $showCover) {
                BattleOrchestratorView(profile: profile, modeType: selectedType)
                    .presentationBackground(.bar)
                    .fadeIn()
            }
            .padding()
    }
}

#Preview {
    ViewPreview {
        PlayView()
    }
}
