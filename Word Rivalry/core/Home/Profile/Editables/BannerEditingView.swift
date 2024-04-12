//
//  BannerEditingView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct BannerEditingView: View {
    @Binding var bannerSelected: String
    @State var profile: PublicProfile
    let content = ContentRepository.shared
    
    var body: some View {
        EditingScrollView(regularNum: 3, compactNum: 2, columnsCount: 3) {
            ForEach(Banner.allCases, id: \.self) { image in
                bannerView(for: image)
            }
        }
    }
    
    @ViewBuilder
    private func bannerView(for image: Banner) -> some View {
        BannerView(banner: image.rawValue)
            .scaleEffect(0.8)
            .selectionOverlay(isSelected: bannerSelected == image.rawValue)
            .scaleEffect(0.7)
            .onTapGesture {
                bannerSelected = image.rawValue
                profile.banner = image.rawValue
            }
    }
}


#Preview {
    BannerEditingView(
        bannerSelected: .constant(Banner.PB_0.rawValue), profile:
            PublicProfile.preview
    )
    .frame(height: 450)
}
