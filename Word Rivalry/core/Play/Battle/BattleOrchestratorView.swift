//
//  BattleOrchestratorView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import SwiftUI
import os.log

struct BattleOrchestratorView: View {
    var battleOrchestrator: BattleOrchestrator
    
    init(profile: PublicProfile, modeType: ModeType) {
        self.battleOrchestrator = BattleOrchestrator(profile: profile, modeType: modeType)
    }
    
    var body: some View {
        Group {
            switch battleOrchestrator.currentPage {
            case .searching:
                SearchingView()
            case .match(let modeType, let gameUUID, let opName):
                MatchView(
                    profile: self.battleOrchestrator.profile,
                    modeType: modeType,
                    gameSessionUUID: gameUUID,
                    opponentUsername: opName
                )
            }
        }
        .environment(self.battleOrchestrator)
        .logLifecycle(viewName: "BattleOrchestratorView")
    }
}

#Preview {
    ViewPreview {
        BattleOrchestratorView(profile: PublicProfile.preview, modeType: .NORMAL)
    }
}
