//
//  AnimatedCirclesView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-22.
//

import SwiftUI

struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [ Color.yellow, Color.purple, Color.blue, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct AnimatedCirclesView: View {
    @State private var isAnimating = false
    
    let tiers = [120, 130.0, 200, 300] // Distance from center for each tier
    let maxScale: CGFloat = 1.5
    let minScale: CGFloat = 0.8
    
    // Variables for trace length and strength
    let traceLength: Double = 0.5 // Duration of the trace effect
    let traceOpacity: Double = 0.5 // Initial opacity of the trace
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<tiers.count, id: \.self) { tierIndex in
                    ForEach(0..<10, id: \.self) { circleIndex in
                        GradientBackgroundView()
                            .mask(
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                    .offset(x: cos(CGFloat(circleIndex) / CGFloat(10) * 2 * .pi) * CGFloat(tiers[tierIndex]),
                                            y: sin(CGFloat(circleIndex) / CGFloat(10) * 2 * .pi) * CGFloat(tiers[tierIndex]))
                            )
                            .scaleEffect(isAnimating ? maxScale : minScale)
                            .opacity(isAnimating ? 0 : 1)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(
                                Animation.easeInOut(duration: 2 + Double(circleIndex) * 0.2)
                                    .repeatForever(autoreverses: true)
                                    .speed(1 / Double(tierIndex + 1))
                                    .delay(Double(tierIndex) * 0.5 + Double(circleIndex) * 0.1),
                                value: isAnimating
                            )
                    }
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
    }
}


#Preview {
    AnimatedCirclesView()
}
