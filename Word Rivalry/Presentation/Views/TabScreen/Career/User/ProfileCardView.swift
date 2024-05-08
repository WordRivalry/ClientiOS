//
//  ProfileCardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI
import GameKit

struct ProfileCardView: View {
    var namespace: Namespace.ID
    @Environment(LocalUser.self) private var localUser
    @State var rotation: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            PortraitView(
                avatar: localUser.user.avatar,
                avatarFrame: localUser.user.avatarFrame,
                namespace: namespace,
                profileImageID: "profileImageView",
                bannerID: "profileBannerView"
            )
            
            UsernameView(username: GKLocalPlayer.local.displayName)
//            TitleView(title: localUser.user.title)
//                .matchedGeometryEffect(id: "titleView", in: namespace)
//            EloRatingView(eloRating: localUser.user.currentPoints)
//                .matchedGeometryEffect(id: "eloRatingView", in: namespace)
        }
        .background(
            ProfileCardBackground(namespace: namespace)
                .frame(width: 200, height: 250)
        )
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                self.rotation = 360
            }
        }
        .logLifecycle(viewName: "ProfileCardView")
    }
}

#Preview {
    @Namespace var namespace
    return ViewPreview {
        ProfileCardView(namespace: namespace)
    }
}
