//
//  ProfileCardBackground.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct ProfileCardBackground: View {
    var namespace: Namespace.ID
    @State var rotation: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(.bar.opacity(0.8))
            .matchedGeometryEffect(id: "profileBackground", in: namespace)
            .overlay {
                RoundedRectangle(cornerRadius: 0, style: .continuous)
                    .foregroundStyle(LinearGradient(colors: [
                        Color.accent.opacity(0.5),
                        Color.accent.opacity(0.5)
                    ], startPoint: .top, endPoint: .bottom))
                    .rotationEffect(.degrees(self.rotation))
                    .matchedGeometryEffect(id: "rotationOverlay", in: namespace)
                    .mask {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(lineWidth: 5)
                            .matchedGeometryEffect(id: "strokeOverlay", in: namespace)
                    }
            }
    }
}

#Preview {
    @Namespace var namespace
    return ProfileCardBackground(namespace: namespace)
}
