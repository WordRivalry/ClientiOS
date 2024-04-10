//
//  ProfileCardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct ProfileCardView: View {
    var namespace: Namespace.ID
    @Environment(PublicProfile.self) private var profile: PublicProfile
    @State var rotation: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            PortraitView(
                profileImage: profile.profileImage,
                banner: profile.banner,
                namespace: namespace,
                profileImageID: "profileImageView",
                bannerID: "profileBannerView"
            )
            PlayerNameView(playerName: profile.playerName)
                .matchedGeometryEffect(id: "playerNameView", in: namespace)
            TitleView(title: profile.computedTitle.rawValue)
                .matchedGeometryEffect(id: "titleView", in: namespace)
            EloRatingView(eloRating: profile.eloRating)
                .matchedGeometryEffect(id: "eloRatingView", in: namespace)
        }
        .background(
            ProfileCardBackground(namespace: namespace)
                .frame(width: 200, height: 300)
        )
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                self.rotation = 360
            }
        }
    }
}

#Preview {
    @Namespace var namespace
    
    return ModelContainerPreview {
        previewContainer
    } content: {
        ProfileCardView(namespace: namespace)
           .environment(PublicProfile.preview)
    }
}
