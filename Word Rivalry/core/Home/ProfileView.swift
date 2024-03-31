//
//  ProfileView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    var namespace: Namespace.ID
    @State var profile: Profile
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ProfileImageWithBannerView
            playerNameView
                .matchedGeometryEffect(id: "playerNameView", in: namespace)
            titleView
                .matchedGeometryEffect(id: "titleView", in: namespace)
            eloRatingView
                .matchedGeometryEffect(id: "eloRatingView", in: namespace)
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .matchedGeometryEffect(id: "profileBackground", in: namespace)
        )
        .shadow(radius: 5)
    }
    
    @ViewBuilder
    var ProfileImageWithBannerView: some View {
        ZStack {
            Image(profile.profileImage)
                .resizable()
                .clipShape(Circle())
                .matchedGeometryEffect(id: "profileImageView", in: namespace)
                .scaledToFill()
                .frame(width: 120, height: 120)
            
            Image(profile.banner)
                .resizable()
                .matchedGeometryEffect(id: "profileBannerView", in: namespace)
                .aspectRatio(contentMode: .fill)
                .frame(width: 140, height: 140)
        }
    }
    
    @ViewBuilder
    var playerNameView: some View {
        Text(self.profile.playerName)
    }
    
    @ViewBuilder
    var titleView: some View {
        Text(self.profile.title)
    }
    
    @ViewBuilder
    var eloRatingView: some View {
        Text("Rating: \(self.profile.eloRating)")
    }
}

struct ProfileView2: View {
    var namespace: Namespace.ID
    @State var profile: Profile
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ProfileImageWithBannerView
                .padding()
            VStack(alignment: .leading,spacing: 10) {
                playerNameView
                    .matchedGeometryEffect(id: "playerNameView", in: namespace)
                Divider()
                titleView
                    .padding(.vertical)
                    .matchedGeometryEffect(id: "titleView", in: namespace)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
//        .background(
//            RoundedRectangle(cornerRadius: 10)
//                .fill(.ultraThinMaterial)
//              
//        )
        .shadow(radius: 5)
    }
    
    @ViewBuilder
    var ProfileImageWithBannerView: some View {
        ZStack {
            Image(profile.profileImage)
                .resizable()
                .clipShape(
                    Circle()
                )
                .matchedGeometryEffect(id: "profileImageView", in: namespace)
                .scaledToFill()
                .frame(width: 150, height: 150)
            
            Image(profile.banner)
                .resizable()
                .matchedGeometryEffect(id: "profileBannerView", in: namespace)
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 160)
        }
    }
    
    @ViewBuilder
    var playerNameView: some View {
        HStack {
               Text(self.profile.playerName)
                   .font(.headline)
               Spacer() // Pushes the content to the left and the icon to the right
               Button(action: {
                   // Action to perform on tap, like showing an edit view
               }) {
                   Image(systemName: "pencil")
               }
               .buttonStyle(BorderlessButtonStyle())
               .accessibilityLabel("Edit player name")
           }
    }
    
    @ViewBuilder
    var titleView: some View {
        Text(self.profile.title)
            .font(.headline)
    }
    
    @ViewBuilder
    var eloRatingView: some View {
        Text("Rating: \(self.profile.eloRating)")
    }
    
//    @ViewBuilder
//    var profileId: some View {
//        VStack(alignment: .center) {
//            Text("Profile ID")
//            HStack {
//                Text(profile.userRecordID)
//                Button(action: {
//                    UIPasteboard.general.string = profile.userRecordID
//                }) {
//                    Image(systemName: "doc.on.doc")
//                }
//                .buttonStyle(BorderlessButtonStyle())
//                .accessibilityLabel("Copy profile ID")
//            }
//        }
//    }
}



#Preview {
    @Namespace var namespace
    return ModelContainerPreview{
        VStack {
            Spacer()
            ProfileView(namespace: namespace, profile: LocalProfile.shared.getProfile())
            Spacer()
            Divider()
            Spacer()
            ProfileView2(namespace: namespace, profile: LocalProfile.shared.getProfile())
            Spacer()
        }
        
    } modelContainer: {
        previewContainer
    }
}
