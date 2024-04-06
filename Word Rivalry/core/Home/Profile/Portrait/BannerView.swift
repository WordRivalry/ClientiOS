//
//  BannerView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct BannerView: View {
    var banner: String
    var namespace: Namespace.ID?
    var id: String?
    
    var body: some View {
        Image(banner)
            .resizable()
            .ifLet(namespace, id) { view, ns, id in
                view.matchedGeometryEffect(id: id, in: ns)
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 140, height: 140)
    }
}



#Preview {
    BannerView(banner: Banner.PB_0.rawValue)
}
