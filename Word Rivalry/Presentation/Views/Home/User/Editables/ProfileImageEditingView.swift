//
//  ProfileImageViewEditing.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct ProfileImageEditingView: View {
    @Binding var profileImageSelected: String
    let content = ContentRepository.shared
    
    var body: some View {
        VStack {
            EditingScrollView(regularNum: 3, compactNum: 2, columnsCount: 3) {
                ForEach(ProfileImage.allCases, id: \.self) { image in
                    profileImageCard(for: image)
                }
            }
        }
    }
    
    @ViewBuilder
    private func profileImageCard(for image: ProfileImage) -> some View {
        ProfileImageView(profileImage: image.rawValue)
            .selectionOverlay(isSelected: profileImageSelected == image.rawValue)
            .scaleEffect(0.8)
            .onTapGesture {
                profileImageSelected = image.rawValue
            }
        
    }
}

#Preview {
    ProfileImageEditingView(
        profileImageSelected: .constant(ProfileImage.PI_0.rawValue)
    )
    .frame(height: 450)
}
