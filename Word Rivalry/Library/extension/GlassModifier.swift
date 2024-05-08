//
//  GlassModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import Foundation

import SwiftUI

struct Glassed: ViewModifier {
    private let gradientColors = [
        Color.white,
        Color.white.opacity(0.1),
        Color.white.opacity(0.1),
        Color.white.opacity(0.4),
        Color.white.opacity(0.5),
    ]
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
            )
    }
}

extension View {
    func glassed() -> some View {
        modifier(Glassed())
    }
}
