//
//  ProfileImageView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct AvatarView: View {
    var avatar: Avatar
    var namespace: Namespace.ID?
    var id: String?
    
    var body: some View {
        Image(avatar.rawValue)
            .resizable()
            .clipShape(Circle())
            .ifLet(namespace, id) { view, ns, id in
                view.matchedGeometryEffect(id: id, in: ns)
            }
            .scaledToFill()
            .frame(width: 120, height: 120)
    }
}

#Preview {
    AvatarView(avatar: .newLeaf)
}
