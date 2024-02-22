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

struct AnimatedCirclesView2: View {
    @ObservedObject var viewModel: AnimatedCirclesViewModel
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<viewModel.tiers.count, id: \.self) { tierIndex in
                    ForEach(0..<10, id: \.self) { circleIndex in
                        // This circle acts as a mask for the gradient
                        GradientBackgroundView()
                            .mask(
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                    .offset(x: cos(CGFloat(circleIndex) / CGFloat(10) * 2 * .pi) * CGFloat(viewModel.tiers[tierIndex]),
                                            y: sin(CGFloat(circleIndex) / CGFloat(10) * 2 * .pi) * CGFloat(viewModel.tiers[tierIndex]))
                            )
                            .scaleEffect(isAnimating ? viewModel.maxScale : viewModel.minScale)
                            .animation(
                                Animation.easeInOut(duration: 1 + Double(circleIndex) * 0.1)
                                    .repeatForever(autoreverses: false)
                                    .speed(1 / Double(tierIndex + 1))
                                    .delay(Double(tierIndex) * 0.1 + Double(circleIndex) * 0.05),
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




struct AnimatedCirclesView: View {
    @State private var isAnimating = false
    
    // Define tiers for the "Saturn's rings" effect
    let tiers = [120, 130.0, 200, 300] // Distance from center for each tier
    let maxScale: CGFloat = 1.5 // Adjusted maximum scale
    let minScale: CGFloat = 0.8 // Minimum scale remains the same
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<tiers.count, id: \.self) { tierIndex in
                    // Create multiple circles within each tier
                    ForEach(0..<10, id: \.self) { circleIndex in
                        
                        GradientBackgroundView()
                            .mask(
                                Circle()
                                    .frame(width: 10, height: 10) // Adjust the size if needed
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                
                                    .offset(x: cos(CGFloat(circleIndex) / CGFloat(10) * 2 * .pi) * CGFloat(tiers[tierIndex]),
                                            y: sin(CGFloat(circleIndex) / CGFloat(10) * 2 * .pi) * CGFloat(tiers[tierIndex]))
                            )
                            .scaleEffect(isAnimating ? maxScale : minScale)
                            .rotationEffect(.degrees(isAnimating ? 180 : 0))
                            .animation(
                                Animation.easeInOut(duration: 1 + Double(circleIndex) * 0.1)
                                    .repeatForever(autoreverses: false)
                                    .speed(1 / Double(tierIndex + 1)) // Adjust rotation speed based on tier
                                    .delay(Double(tierIndex) * 1 + Double(circleIndex) * 1),
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
//
//struct AnimatedCirclesView: View {
//    @ObservedObject var viewModel: AnimatedCirclesViewModel
//    @State private var isAnimating = false
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                ForEach(0..<viewModel.tiers.count, id: \.self) { tierIndex in
//                    ForEach(0..<10, id: \.self) { circleIndex in
//                        Circle()
//                            .fill(self.circleColor(for: tierIndex)) // Use viewModel colors
//                            .frame(width: 10, height: 10)
//                            .scaleEffect(isAnimating ? viewModel.maxScale : viewModel.minScale)
//                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
//                            .offset(x: cos(CGFloat(circleIndex) / CGFloat(10) * 2 * .pi) * CGFloat(viewModel.tiers[tierIndex]),
//                                    y: sin(CGFloat(circleIndex) / CGFloat(10) * 2 * .pi) * CGFloat(viewModel.tiers[tierIndex]))
//                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
//                            .animation(
//                                Animation.easeInOut(duration: 1 + Double(circleIndex) * 0.1)
//                                    .repeatForever(autoreverses: false)
//                                    .speed(1 / Double(tierIndex + 1))
//                                    .delay(Double(tierIndex) * 0.1 + Double(circleIndex) * 0.05),
//                                value: isAnimating
//                            )
//                    }
//                }
//            }
//            .onAppear {
//                isAnimating = true
//            }
//        }
//    }
//
//    func circleColor(for tier: Int) -> Color {
//        return viewModel.colors.count > tier ? viewModel.colors[tier] : .gray // Fallback to gray if not enough colors are provided
//    }
//}


#Preview {
    AnimatedCirclesView()
}
