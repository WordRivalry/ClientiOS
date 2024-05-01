//
//  SheetCoordinating.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import Foundation
import SwiftUI

struct SheetCoordinating<Sheet: ModalEnum>: ViewModifier {
    @State var coordinator: ModalCoordinator<Sheet>

    func body(content: Content) -> some View {
        content
            .sheet(item: $coordinator.currentModal, onDismiss: {
                coordinator.modalDismissed()
            }, content: { sheet in
                sheet.view(coordinator: coordinator)
                    .presentationBackground(.bar)
                    .fadeIn()
            })
    }
}
extension View {
    func sheetCoordinating<Sheet: ModalEnum>(coordinator: ModalCoordinator<Sheet>) -> some View {
        modifier(SheetCoordinating(coordinator: coordinator))
    }
}


