//
//  CardBackgroundModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI

struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 5)
            .background(.bar) // Assuming .bar is a defined color
            .cornerRadius(10)
            .shadow(radius: 2)
         
    }
}

extension View {
    func cardBackground() -> some View {
        self.modifier(CardBackgroundModifier())
    }
}
