//
//  ProfileNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-22.
//

import SwiftUI

struct ProfileNavigationStack: View {
    @EnvironmentObject var profileService: ProfileService
    @State private var username: String = ""
    @State private var showingFriendsList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    BasicNavButton(text: "Profile", destination: ProfileView())
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
            .navigationTitle(username)
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
            .onAppear {
               username = profileService.getUsername()
            }
   
        }
 
    }
}

#Preview {
    HomeNavigationStack()
        .environmentObject(ProfileService())
}


#Preview {
    ProfileNavigationStack()
}
