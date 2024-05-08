//
//  BannerView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct AvatarFrameView: View {
    var avatarFrame: AvatarFrame
    var namespace: Namespace.ID?
    var id: String?
    
    var body: some View {
        Image(avatarFrame.rawValue)
            .resizable()
            .ifLet(namespace, id) { view, ns, id in
                view.matchedGeometryEffect(id: id, in: ns)
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 140, height: 140)
    }
}



#Preview {
    AvatarFrameView(avatarFrame: .gold)
}
