//
//  ProfilePortraitView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct PortraitView: View {
    var profileImage: String
    var banner: String
    var namespace: Namespace.ID?
    var profileImageID: String?
    var bannerID: String?
    var portraitID: String?
    
    // For scenario 1: Defaut use case
    init(profileImage: String, banner: String) {
        self.profileImage = profileImage
        self.banner = banner
    }
    
    // For scenario 2: Providing profile image ID, banner ID, and namespace
    init(profileImage: String, banner: String, namespace: Namespace.ID, profileImageID: String, bannerID: String) {
        self.profileImage = profileImage
        self.banner = banner
        self.namespace = namespace
        self.profileImageID = profileImageID
        self.bannerID = bannerID
    }
    
    // For scenario 3: Providing namespace and portrait ID
    init(profileImage: String, banner: String, namespace: Namespace.ID, profileImageID: String, bannerID: String, portraitID: String) {
        self.profileImage = profileImage
        self.banner = banner
        self.namespace = namespace
        self.profileImageID = profileImageID
        self.bannerID = bannerID
    }
    
    var body: some View {
        ZStack {
            ProfileImageView(
                profileImage: profileImage,
                namespace: namespace,
                id: profileImageID
            )
            BannerView(
                banner: banner,
                namespace: namespace,
                id: bannerID
            )
        }
        .ifLet(namespace, portraitID) { view, ns, id in
            view.matchedGeometryEffect(id: id, in: ns)
        }
    }
}

#Preview {
    PortraitView(
        profileImage: ProfileImage.PI_0.rawValue,
        banner: Banner.PB_0.rawValue
    )
}
