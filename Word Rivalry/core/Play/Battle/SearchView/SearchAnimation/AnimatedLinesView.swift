//
//  AnimatedLineView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI

//struct AnimatedLinesView: View {
//    @State private var isAnimating = false
//
//    // Define tiers for the pulsating lines effect
//    let tiers: [CGFloat] = [120, 130, 200, 300] // Distance from center for each tier
//    let maxScale: CGFloat = 1.5 // Adjusted maximum scale for the pulsation
//    let minScale: CGFloat = 0.8 // Minimum scale for the pulsation
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                ForEach(0..<tiers.count, id: \.self) { tierIndex in
//                    // Create multiple lines within each tier
//                    ForEach(0..<10, id: \.self) { lineIndex in
//                        LineView()
//                            .stroke(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
//                            .frame(width: 2, height: 30) // Adjust the size of the line if needed
//                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
//                            .offset(x: cos(CGFloat(lineIndex) / CGFloat(10) * 2 * .pi) * tiers[tierIndex],
//                                    y: sin(CGFloat(lineIndex) / CGFloat(10) * 2 * .pi) * tiers[tierIndex])
//                            .scaleEffect(isAnimating ? maxScale : minScale)
//                            .opacity(isAnimating ? 0 : 1)
//                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
//                            .animation(
//                                Animation.easeInOut(duration: 2 + Double(lineIndex) * 0.5)
//                                    .repeatForever(autoreverses: true)
//                                    .speed(1 / Double(tierIndex + 1)) // Adjust rotation speed based on tier
//                                    .delay(Double(tierIndex) * 0.5 + Double(lineIndex) * 0.1),
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
//}

//struct LineView: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
//        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
//        return path
//    }
//}

//#Preview {
//    AnimatedLinesView()
//}
