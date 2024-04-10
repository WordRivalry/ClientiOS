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
    @State var lockedImageSelected: String?
    @Environment(AchievementsProgression.self) private var progs: AchievementsProgression
    let content = ContentRepository.shared
    
    var body: some View {
        VStack {
            ContentRequirementView
            Spacer()
            EditingScrollView(regularNum: 3, compactNum: 2, columnsCount: 3) {
                ForEach(Banner.allCases, id: \.self) { image in
                    bannerView(for: image)
                }
            }
    
        }
    }
    
    
    @ViewBuilder
    private func bannerView(for image: Banner) -> some View {
        
        let isUnlocked = content.isUnlocked(using: progs, image)
        
        if isUnlocked {
            BannerView(banner: image.rawValue)
                .scaleEffect(0.8)
                .selectionOverlay(isSelected: bannerSelected == image.rawValue)
                .scaleEffect(0.7)
                .onTapGesture {
                    lockedImageSelected = nil
                    bannerSelected = image.rawValue
                    profile.banner = image.rawValue
                }
        } else {
            BannerView(banner: image.rawValue)
                .scaleEffect(0.8)
                .selectionOverlay(isSelected: bannerSelected == image.rawValue)
                .scaleEffect(0.7)
                .onTapGesture {
                    lockedImageSelected = image.rawValue
                }
                .overlay {
                    Image(systemName: "lock")
                        .resizable()
                        .scaleEffect(0.2)
                        .foregroundStyle(.red)
                        .offset(CGSize(width: 40.0, height: 50.0))
                }
        }
    }
    
    @ViewBuilder
    private var ContentRequirementView: some View {
        if (lockedImageSelected == nil) {
            if let banner = Banner(rawValue: bannerSelected) {
                if let achievementName = content.getAchievement(for: banner) {
                    Divider()
                    HStack {
                        Text("Achievement :")
                        Text("\(achievementName.rawValue)")
                            .foregroundStyle(.cyan)
                            .onTapGesture {
                                print("Tapped")
                            }
                    }
                } else {
                    Divider().opacity(0.01)
                    Text("Basic")
                }
            } else {
                Divider().opacity(0.01)
                Text("Basic")
            }
        } else {
            if let banner = Banner(rawValue: bannerSelected) {
                if let achievementName = content.getAchievement(for: banner) {
                    Divider()
                    HStack {
                        Text("Achievement :")
                        Text("\(achievementName.rawValue)")
                            .foregroundStyle(.red)
                            .onTapGesture {
                                print("Tapped")
                            }
                    }
                }
            }
        }
        
    }
}


#Preview {
    BannerEditingView(
        bannerSelected: .constant(Banner.PB_0.rawValue), profile:
            PublicProfile.preview
    )
    .environment(AchievementsProgression.preview)
    .frame(height: 450)
}
