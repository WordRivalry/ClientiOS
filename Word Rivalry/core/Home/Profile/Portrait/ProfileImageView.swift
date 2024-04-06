//
//  ProfileImageView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct ProfileImageView: View {
    var profileImage: String
    var namespace: Namespace.ID?
    var id: String?
    
    var body: some View {
        Image(profileImage)
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
    @Namespace var namespace
    return ProfileImageView(profileImage: ProfileImage.PI_0.rawValue)
}
