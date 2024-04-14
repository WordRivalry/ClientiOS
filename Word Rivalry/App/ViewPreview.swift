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
   //     ModelContainerPreview {
   //         previewContainer
   //     } content: {
            content()
                .environment(SYPData<Profile>.preview)
                .environment(SYPData<MatchHistoric>.preview)
                .environment(BattleOrchestrator(profile: PublicProfile.preview, modeType: .NORMAL))
                .environment(PublicProfile.preview)
                .environment(Network())
                .environment(Profile.preview)
            //   .environment(Friends.preview)
                .environment(LeaderboardService.preview)
                .environment(InGameDisplaySettings())
                .navigationBarColor(.white)
   //     }
    }
}
