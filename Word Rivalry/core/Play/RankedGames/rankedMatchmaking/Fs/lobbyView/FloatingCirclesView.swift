//
//  FloatingCirclesView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI

struct FloatingCirclesView: View {
    @State private var position1 = 0.1
    @State private var position2 = 0.8
    @State private var position3 = 0.5

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let height1 = size.height * 0.2
            let height2 = size.height * 0.3
            let height3 = size.height * 0.7
            
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 100, height: 100)
                .position(x: size.width * position1, y: height1)
                .blur(radius: 3)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        position1 = 0.9 - position1
                    }
                }
            
            Circle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 150, height: 150)
                .position(x: size.width * position2, y: height2)
                .blur(radius: 3)
                .blendMode(.difference)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                        position2 = 0.9 - position2
                    }
                }
            
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 120, height: 120)
                .position(x: size.width * position3, y: height3)
                .blur(radius: 3)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                        position3 = 0.9 - position3
                    }
                }
        }
    }
}

#Preview {
    FloatingCirclesView()
}
