//
//  ViewPreview.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import SwiftUI

struct ViewPreview<Content: View>: View {
    var content: () -> Content
    
    @State private var ownProfile = PublicProfile.preview
    @State private var opProfile = PublicProfile.previewOther
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        
        
        
        ModelContainerPreview {
            previewContainer
        } content: {
            content()
                .environment(AppServiceManager())
                .environment(Network())
                .environment(GlobalOverlay.shared)
                .environment(MyPublicProfile.preview)
                .environment(MyPersonalProfile.preview)
                .environment(JITLeaderboard.preview)
                .environment(PurchaseManager())
                .environment(MatchHistoric.preview)
                .environment(InGameDisplaySettings())
                .environment(GameViewModel())
                .environment(MainRouter())
                .environment(ownProfile)
                .environment(MatchService(ownProfile: ownProfile))
            
                .navigationBarColor(.white)
        }
    }
}
