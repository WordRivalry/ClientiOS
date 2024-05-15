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
        content()
            .environment(GlobalOverlay.shared)
            .environment(LocalUser.preview)
            .environment(PurchaseManager())
            .environment(InGameDisplaySettings())
            .environment(SoloGameViewModel.preview)
            .environment(MainRouter())
            .navigationBarColor(.white)
    }
}
