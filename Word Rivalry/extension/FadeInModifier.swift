//
//  FadeInModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-05.
//

import SwiftUI

struct FadeInModifier: ViewModifier {
    @State private var opacity = 0.0

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 1.0
                }
            }
    }
}

extension View {
    func fadeIn() -> some View {
        self.modifier(FadeInModifier())
    }
}

