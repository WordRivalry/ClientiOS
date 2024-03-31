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
    @State var showDetailedProfile = false
    @Namespace var namespace
    
    @Environment(\.modelContext) private var modelContext
    @Query(Profile.local) var SD_profiles: [Profile]
    var profile: Profile? { SD_profiles.first }
    
    // Initialize the achievements manager and subscribe it to the event system

    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    if (!showDetailedProfile) {
                        ProfileView(namespace: namespace, profile: profile!)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    showDetailedProfile = true
                                }
                            }
                        
                        BasicNavButton(text: "Leaderboard", destination: LeaderboardView())
                            .matchedGeometryEffect(id: "button0", in: namespace)
                        
                        BasicNavButton(text: "Statistics", destination: StatisticsView())
                            .matchedGeometryEffect(id: "button1", in: namespace)
                        
                        BasicNavButton(text: "Friends", destination: FriendsListView())
                            .matchedGeometryEffect(id: "button2", in: namespace)
                    } else {
                        ProfileDetailView(
                            namespace: namespace,
                            profile: profile!,
                            showDetailView: $showDetailedProfile
                        )
                            .matchedGeometryEffect(id: "profileDetailView", in: namespace)
                           
                            .background(
                                RoundedRectangle(cornerRadius: 25.0).fill(.white.opacity(0.2))
                                    .matchedGeometryEffect(id: "profileBackground", in: namespace)
                            )
                            .padding()
                       
                    }
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
            // .navigationTitle(LocalProfile.shared.getProfile().playerName)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar {
//                if !showDetailedProfile {
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
//                    }
                   
                }
                
            }
        }
        .onAppear {
            EventSystem.shared.subscribe(AchievementsManager.shared, to: [PlayerActionEventType.buttonClick])
        }
    }
}

#Preview {
    ModelContainerPreview{
        HomeNavigationStack()
    } modelContainer: {
        previewContainer
    }
}
