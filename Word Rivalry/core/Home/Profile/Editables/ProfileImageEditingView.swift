//
//  ProfileImageViewEditing.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct ProfileImageEditingView: View {
    @Binding var profileImageSelected: String
    @State var lockedImageSelected: String?
    @Environment(AchievementsProgression.self) private var progs: AchievementsProgression
    let content = ContentRepository.shared
    
    var body: some View {
        VStack {
            ContentRequirementView
            Spacer()
            EditingScrollView(regularNum: 3, compactNum: 2, columnsCount: 3) {
                ForEach(ProfileImage.allCases, id: \.self) { image in
                    profileImageCard(for: image)
                }
            }
        }
    }
    
    @ViewBuilder
    private func profileImageCard(for image: ProfileImage) -> some View {
        let isUnlocked = content.isUnlocked(using: progs, image)
        
        if isUnlocked {
            ProfileImageView(profileImage: image.rawValue)
                .selectionOverlay(isSelected: profileImageSelected == image.rawValue)
                .scaleEffect(0.8)
                .onTapGesture {
                    lockedImageSelected = nil
                    profileImageSelected = image.rawValue
                }
        } else {
            ProfileImageView(profileImage: image.rawValue)
                .selectionOverlay(isSelected: profileImageSelected == image.rawValue)
                .onTapGesture {
                    lockedImageSelected = image.rawValue
                }
                .scaleEffect(0.8)
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
        VStack {
            
            if (lockedImageSelected == nil) {
                if let profileImage = ProfileImage(rawValue: profileImageSelected) {
                    if let achievementName = content.getAchievement(for: profileImage) {
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
                if let profileImage = ProfileImage(rawValue: lockedImageSelected!) {
                    if let achievementName = content.getAchievement(for: profileImage) {
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
}

#Preview {
    ProfileImageEditingView(
        profileImageSelected: .constant(ProfileImage.PI_0.rawValue)
    )
    .frame(height: 450)
    .environment(AchievementsProgression.preview)
}
