//
//  FullscreenCoverCoordinating.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import SwiftUI

struct FullScreenCoverCoordinating<FullScreenCover: ModalEnum>: ViewModifier {
    @State var coordinator: ModalCoordinator<FullScreenCover>
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $coordinator.currentModal, onDismiss: {
                coordinator.modalDismissed()
            }, content: { fullScreenCover in
                fullScreenCover.view(coordinator: coordinator)
                    .presentationBackground(.bar)
                    .fadeIn()
            })
    }
}

extension View {
    func fullScreenCoverCoordinating<FullScreenCover: ModalEnum>(coordinator: ModalCoordinator<FullScreenCover>) -> some View {
        modifier(FullScreenCoverCoordinating(coordinator: coordinator))
    }
}
