//
//  WaveAnimationView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-24.
//

import SwiftUI

struct NucleusView: View {
    @State private var animate = false

    let size: CGFloat = 20
    let delay: Double

    init(delay: Double) {
        self.delay = delay
    }

    var body: some View {
        ZStack {
            // Circle for the nucleus
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(Color.accentColor.opacity(0.5))
            
            // Cross effect
            ForEach(0..<4) { index in
                Rectangle()
                    .frame(width: 2, height: size * (animate ? 2 : 1))
                    .foregroundColor(Color.accentColor.opacity(0.5))
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
        .scaleEffect(animate ? 0 : 1)
        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(delay), value: animate)
        .onAppear {
            self.animate = true
        }
    }
}

struct LightningView: Shape {
    var points: [CGPoint]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        
        path.move(to: points.first!)
        points.dropFirst().forEach { path.addLine(to: $0) }
        return path
    }
}

struct NucleusPosition: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let position: CGPoint

    static func == (lhs: NucleusPosition, rhs: NucleusPosition) -> Bool {
        return lhs.id == rhs.id && lhs.position == rhs.position
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
}

struct NucleusBackgroundView: View {
    var nucleiCount: Int = 50
    @State private var nuclei: [NucleusPosition] = []
    @State private var lightningPath: [CGPoint] = []
    @State private var showLightning: Bool = false
    @State private var trimEnd: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(nuclei) { nucleus in
                    NucleusView(delay: Double.random(in: 0...3))
                        .position(nucleus.position)
                }
                
                if showLightning {
                    LightningView(points: lightningPath)
                        .trim(from: 0, to: trimEnd)
                        .stroke(Color.white, lineWidth: 2)
                }
            }
            .onAppear {
                nuclei = (0..<nucleiCount).map { _ in
                    NucleusPosition(position: CGPoint(x: CGFloat.random(in: 0...geometry.size.width),
                                                      y: CGFloat.random(in: 0...geometry.size.height)))
                }
                periodicallyTriggerLightning()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    
    func generateLightningPath() {
        lightningPath = nuclei.shuffled().prefix(5).map { $0.position }
    }
    
    func periodicallyTriggerLightning() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            self.generateLightningPath()
            self.showLightning = true
          //  self.trimEnd = 0 // Reset the trim end before starting animation
            
            // Start the animation using AnimationManager
            AnimationManager.shared.startAnimation(
                duration: 0.3,
                curve: .easeInOut,
                onProgress: { progress in
                    DispatchQueue.main.async {
                        self.trimEnd = progress
                    }
                },
                onComplete: {
                    DispatchQueue.main.async {
                        self.showLightning = false
                    }
                }
            )
        }
    }
}


#Preview {
    NucleusBackgroundView()
}
