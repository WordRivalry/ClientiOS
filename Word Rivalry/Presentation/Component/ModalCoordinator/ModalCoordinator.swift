//
//  SheetCoordinator.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import Foundation

@Observable final class ModalCoordinator<Modal: ModalEnum> {
    var currentModal: Modal?
    private var modalStack: [Modal] = []

    @MainActor
    func presentModal(_ sheet: Modal) {
        modalStack.append(sheet)

        if modalStack.count == 1 {
            currentModal = sheet
        }
    }

    @MainActor
    func modalDismissed() {
        modalStack.removeFirst()

        if let nextModal = modalStack.first {
            currentModal = nextModal
        }
    }
}
