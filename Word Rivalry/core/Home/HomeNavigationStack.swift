//
//  HomeNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import SwiftData

class LocalProfile {
    static let shared = LocalProfile()
    
    private var profile: Profile?
    private init() {}
    
    func setProfile(profile :Profile) {
        self.profile = profile
    }
    
    func getProfile() -> Profile {
        if let profile = self.profile {
            return profile
        } else {
            return Profile.preview
        }
       
    }
}

struct HomeNavigationStack: View {
    @State private var showingFriendsList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    BasicNavButton(text: "Leaderboard", destination: LeaderboardView())
                    BasicNavButton(text: "Statistics", destination: StatisticsView())
                    BasicNavButton(text: "Friends", destination: FriendsListView())
                }
                
                if (showingFriendsList) {
                    FriendsListView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            .ultraThinMaterial
                        )
                        .onTapGesture {
                            withAnimation(.easeOut) {
                                showingFriendsList = false
                            }
                        }
                }
            }
            .navigationTitle(LocalProfile.shared.getProfile().playerName)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    if (!showingFriendsList) {
                        Button(action: {
                            withAnimation(.easeIn) {
                                showingFriendsList = true
                            }
                        }) {
                            Image(systemName: "person.3.fill")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeNavigationStack()
        .modelContainer(previewContainer)
}
