//
//  ProfileCardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct ProfileCardView: View {
    var namespace: Namespace.ID
    @Environment(MyPublicProfile.self) private var profile
    @State var rotation: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            PortraitView(
                profileImage: profile.publicProfile.profileImage,
                banner: profile.publicProfile.banner,
                namespace: namespace,
                profileImageID: "profileImageView",
                bannerID: "profileBannerView"
            )
//            PlayerNameView(playerName: profile.playerName)
//                .matchedGeometryEffect(id: "playerNameView", in: namespace)
            TitleView(title: profile.publicProfile.computedTitle.rawValue)
                .matchedGeometryEffect(id: "titleView", in: namespace)
            EloRatingView(eloRating: profile.publicProfile.eloRating)
                .matchedGeometryEffect(id: "eloRatingView", in: namespace)
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
