//
//  ViewPreview.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import SwiftUI

struct ViewPreview<Content: View>: View {
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ModelContainerPreview {
            previewContainer
        } content: {
            content()
                .environment(BattleOrchestrator(profile: PublicProfile.preview, modeType: .NORMAL))
                .environment(PublicProfile.preview)
                .environment(Friends.preview)
                .environment(Network())
                .environment(Profile.preview)
                .environment(LeaderboardService.preview)
                .environment(InGameDisplaySettings())
                .navigationBarColor(.white)
        }
    }
}
