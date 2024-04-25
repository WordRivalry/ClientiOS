//
//  ViewPreview.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import SwiftUI

struct ViewPreview<Content: View>: View {
    var content: () -> Content
    
    @State private var ownProfile = User.preview
    @State private var opProfile = User.previewOther
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        ModelContainerPreview {
            previewContainer
        } content: {
            content()
                .environment(Network())
                .environment(GlobalOverlay.shared)
                .environment(UserViewModel.preview)
                .environment(LeaderboardViewModel.preview)
                .environment(PurchaseManager())
                .environment(MatchRecord.preview)
                .environment(InGameDisplaySettings())
                .environment(GameViewModel.preview)
                .environment(MainRouter())
                .environment(ownProfile)
                .navigationBarColor(.white)
        }
    }
}
