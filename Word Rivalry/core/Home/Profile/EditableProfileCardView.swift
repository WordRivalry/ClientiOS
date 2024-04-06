//
//  EditableProfileCard.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct EditableProfileCardView: View {
    var namespace: Namespace.ID
    @Environment(Profile.self) private var profile: Profile
    @State var rotation: CGFloat = 0
    @State var showEditNameAlert: Bool = false
    @State var textField: String = ""
    @State private var selectedTabIndex = 0
    private let tabs = ["Picture", "Banner", "Title"]
    
    var body: some View {
        VStack {
            profileView
                .padding(.horizontal)
            Divider()
            customTabView
        }
        .background(
            ProfileCardBackground(namespace: namespace)
        )
        .padding()
    }
    
    @ViewBuilder
    var profileView: some View {
        HStack(alignment: .center) {
            PortraitView(
                profileImage: profile.profileImage,
                banner: profile.banner,
                namespace: namespace,
                profileImageID: "profileImageView",
                bannerID: "profileBannerView"
            )
            .scaleEffect(0.8)
            
            Spacer()
            
            VStack(alignment: .leading,spacing: 10) {
                PlayerNameView(playerName: profile.playerName)
                    .matchedGeometryEffect(id: "playerNameView", in: namespace)
                    .frame(width: 150)
                TitleView(title: profile.title)
                    .padding(.vertical)
                    .matchedGeometryEffect(id: "titleView", in: namespace)
                    .frame(width: 150)
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var playerNameView: some View {
        HStack(spacing: 20) {
            PlayerNameView(playerName: profile.playerName)
                .font(.headline)
            Button(action: {
                showEditNameAlert = true
            }) {
                Image(systemName: "pencil")
                    .tint(.accent)
            }
            .alert(Text("Write desired player name"),
                   isPresented: $showEditNameAlert,
                   actions: {
                Button("Confirm") { }
                Button("Cancel", role: .cancel) {}
            }, message: {
                TextField("Player Name", text: $textField, onCommit: {
                    // Update the profile's player name with the edited value on commit
                    profile.playerName = self.textField
                })
            })
        }
    }
    
    @ViewBuilder
    private var customTabView: some View {
        VStack {
            tabView
            Spacer()
            tabContentView
        }
    }
    
    @ViewBuilder
    var tabView: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { index in
                Text(tabs[index])
                    .matchedGeometryEffect(id: "button\(index)", in: namespace)
                    .frame(width: 100, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(selectedTabIndex == index ? Color.accent : Color.white)
                    )
                    .foregroundStyle(.black)
                    .cornerRadius(10)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            selectedTabIndex = index
                        }
                    }
            }
        }
    }

    @ViewBuilder
    var tabContentView: some View {
        @Bindable var profile = profile
        Group {
            switch selectedTabIndex {
            case 0:
                ProfileImageEditingView(
                    profileImageSelected: $profile.profileImage
                )
            case 1:
                BannerEditingView(
                    bannerSelected: $profile.banner,
                    profile: profile
                )
            case 2:
                TitleEditingView(
                    titleSelected: $profile.title,
                    profile: profile
                )
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    @Namespace var namespace
    
    return ModelContainerPreview {
        previewContainer
    } content: {
        EditableProfileCardView(namespace: namespace)
           .environment(Profile.preview)
           .environment(AchievementsProgression.preview)
    }
}



