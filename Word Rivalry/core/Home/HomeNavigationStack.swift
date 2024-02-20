//
//  HomeNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

struct HomeNavigationStack: View {
    @EnvironmentObject var profileService: ProfileService
    @State private var username: String = "Fetching..."
    @State private var showingFriendsList = false
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                VStack(spacing: 20) {
                    BasicButton(text: "Profile", destination: ProfileView())
                    BasicButton(text: "Leaderboard", destination: LeaderboardView())
                    BasicButton(text: "Statistics", destination: StatisticsView())
                    BasicButton(text: "Friends", destination: FriendsListView())
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    if (!showingFriendsList) {
                        Button(action: {
                            withAnimation(.easeIn) {
                                showingFriendsList = true
                            }
                        }) {
                          //  Image(systemName: "person.3.fill")
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        username = try await profileService.fetchUsername()
                    } catch {
                        username = "Lightcastle"
                    }
                }
            }
        }
    }
}

#Preview {
    HomeNavigationStack()
        .environmentObject(ProfileService())
}
