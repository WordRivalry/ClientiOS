//
//  SelectionOverlayModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-05.
//

import SwiftUI

struct SelectionOverlayModifier: ViewModifier {
    var isSelected: Bool
    func body(content: Content) -> some View {
        content
            .overlay(
                isSelected ? RotatingCircleGradientStroke() : nil
            )
    }
}

extension View {
    func selectionOverlay(isSelected: Bool) -> some View {
        self.modifier(SelectionOverlayModifier(isSelected: isSelected))
    }
}

#Preview {
    Circle()
        .selectionOverlay(isSelected: true)
}
