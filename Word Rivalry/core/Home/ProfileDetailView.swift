//
//  DetailedProfileView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-29.
//

import Foundation
import SwiftUI
import SwiftData

struct ProfileDetailView: View {
    var namespace: Namespace.ID
    @State var profile: Profile
    @Binding var showDetailView: Bool
    
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTabIndex = 0
    
    private let tabs = ["Picture", "Banner", "Title"]
    
    var body: some View {
        VStack {
            upperProfileView
                .onTapGesture {
                    withAnimation {
                        showDetailView = false
                    }
                }
            Divider()
            AchievementsView(unlockedAchievementIDs: Set(profile.unlockedAchievementIDs))
            customTabView
        }     
    }
    
    @ViewBuilder
    private var upperProfileView: some View {
       ProfileView2(namespace: namespace, profile: profile)
    }
    
    @ViewBuilder
    private var customTabView: some View {
        VStack {
            HStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Text(tabs[index])
                        .matchedGeometryEffect(id: "button\(index)", in: namespace)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(selectedTabIndex == index ? Color.accent : Color.white)
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation(.bouncy) {
                                selectedTabIndex = index
                            }
                        }
                }
            }
            .opacity(showDetailView ? 1 : 0)
            .padding(.bottom, 5)
            
            // This switch statement controls which view is displayed based on the selected tab.
            switch selectedTabIndex {
            case 0:
                ProfileImageViewEditing(namespace: namespace, profileImageSelected: $profile.profileImage)
            case 1:
                ProfileBannerViewEditing(namespace: namespace, bannerSelected: $profile.banner)
            case 2:
                ProfileTitleViewEditing(namespace: namespace, titleSelected: $profile.title)
            default:
                EmptyView()
            }
        }
        .padding()
        .shadow(radius: 5)
    }
}

struct ProfileImageViewEditing: View {
    var namespace: Namespace.ID
    @Binding var profileImageSelected: String

    // Define the grid layout
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: 3)

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                // Use LazyVGrid to create a grid layout
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(ProfileImage.allCases, id: \.self) { image in
                        Image(image.rawValue)
                            .resizable()
                            .frame(width: 90, height: 90)
                            .mask(
                                Circle()
                            )
                            .overlay(
                                Circle().stroke(
                                    profileImageSelected == image.rawValue ? Color.white : Color.accentColor,
                                    lineWidth: 4
                                )
                            )
                            .scaledToFit()
                            .onTapGesture {
                                profileImageSelected = image.rawValue
                            }
                    }
                }
                .padding()
                //.background(.ultraThinMaterial)
            }
        }
    }
}

struct ProfileBannerViewEditing: View {
    var namespace: Namespace.ID
    @Binding var bannerSelected: String
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(Banner.allCases, id: \.self) { banner in
                        Image(banner.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .border(Color.blue, width: bannerSelected == banner.rawValue ? 3 : 0)
                            .onTapGesture {
                                bannerSelected = banner.rawValue
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ProfileTitleViewEditing: View {
    var namespace: Namespace.ID
    @Binding var titleSelected: String
    
    var body: some View {
        VStack {
            Picker("Title", selection: $titleSelected) {
                ForEach(Title.allCases, id: \.self) { title in
                    Text(title.rawValue).tag(title.rawValue)
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
        .frame(maxHeight: .infinity)
    }
}


#Preview {
    @Namespace var namespace
    return ModelContainerPreview{
        VStack {}
            .blurredOverlay(isPresented: .constant(true)) {
                ProfileDetailView(namespace: namespace, profile: Profile.preview, showDetailView: .constant(true))
            }
    } modelContainer: {
        previewContainer
    }
}
