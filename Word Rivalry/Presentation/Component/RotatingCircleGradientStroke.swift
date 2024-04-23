//
//  GradiantStroke.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import Foundation
import SwiftUI

struct RotatingCircleGradientStroke: View {
    @State private var isAnimating = false
    
    
    var body: some View {
        Circle()
            .stroke(lineWidth: 4)
            .padding(-8) // Adjust padding based on stroke width
            .mask(
                AngularGradient(gradient: gradientColors, center: .center)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(Animation.linear(duration: 10).repeatForever(autoreverses: false), value: isAnimating)
                    .onAppear { isAnimating = true }
            )
    }
    
    private var gradientColors: Gradient {
        Gradient(colors: [.white.opacity(0.5)])
    }
}

struct RotatingRectangleGradientStroke: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .stroke(lineWidth: 4)
            .padding(-4) // Adjust padding based on stroke width
            .mask(
                AngularGradient(gradient: gradientColors, center: .center)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(Animation.linear(duration: 10).repeatForever(autoreverses: false), value: isAnimating)
                    .onAppear { isAnimating = true }
            )
    }
    
    private var gradientColors: Gradient {
        Gradient(colors: [.black])
    }
}

#Preview {
    Circle()
        .frame(width: 100)
        .overlay {
            RotatingCircleGradientStroke()
        }
}
