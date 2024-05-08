//
//  ProfilePortraitView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct PortraitView: View {
    var avatar: Avatar
    var avatarFrame: AvatarFrame
    var namespace: Namespace.ID?
    var profileImageID: String?
    var bannerID: String?
    var portraitID: String?
    
    // For scenario 1: Defaut use case
    init(avatar: Avatar, avatarFrame: AvatarFrame) {
        self.avatar = avatar
        self.avatarFrame = avatarFrame
    }
    
    // For scenario 2: Providing profile image ID, banner ID, and namespace
    init(avatar: Avatar, avatarFrame: AvatarFrame, namespace: Namespace.ID, profileImageID: String, bannerID: String) {
        self.avatar = avatar
        self.avatarFrame = avatarFrame
        self.namespace = namespace
        self.profileImageID = profileImageID
        self.bannerID = bannerID
    }
    
    // For scenario 3: Providing namespace and portrait ID
    init(avatar: Avatar, avatarFrame: AvatarFrame, namespace: Namespace.ID, profileImageID: String, bannerID: String, portraitID: String) {
        self.avatar = avatar
        self.avatarFrame = avatarFrame
        self.namespace = namespace
        self.profileImageID = profileImageID
        self.bannerID = bannerID
    }
    
    var body: some View {
        ZStack {
            AvatarView(
                avatar: avatar,
                namespace: namespace,
                id: profileImageID
            )
            if avatarFrame != .none {
                AvatarFrameView(
                    avatarFrame: avatarFrame,
                    namespace: namespace,
                    id: bannerID
                )
            }
        }
        .ifLet(namespace, portraitID) { view, ns, id in
            view.matchedGeometryEffect(id: id, in: ns)
        }
    }
}

#Preview {
    PortraitView(
        avatar: .newLeaf,
        avatarFrame: .none
    )
}
