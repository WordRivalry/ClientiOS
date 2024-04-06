//
//  HomeNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
struct HomeNavigationStack: View {
    @Environment(Profile.self) private var profile: Profile
    @Namespace var namespace
    
    @State private var showDetailedProfile = false
    @State private var showFriendsList = false
    @State private var showLeaderboard = false
    @State private var showAchievements = false
    @State private var showStatictics = false
    
    // Initialize the achievements manager and subscribe it to the event systemå
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    if (!showDetailedProfile) {
                        ProfileCardView(namespace: namespace)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    showDetailedProfile = true
                                }
                            }
                            .padding(.bottom).padding(.bottom)
                        
                        BasicButton(text: "Leaderboard") {
                            showLeaderboard = true
                        }
                        .matchedGeometryEffect(id: "button0", in: namespace)
                        
                        BasicButton(text: "Statistics") {
                            showStatictics = true
                        }
                        .matchedGeometryEffect(id: "button1", in: namespace)
                        
                        BasicButton(text: "Achievements") {
                            showAchievements = true
                        }
                        .matchedGeometryEffect(id: "button2", in: namespace)
                    } else {
                        EditableProfileCardView(
                            namespace: namespace
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    Color.background
                    
//                    Image("bgMotif")
//                        .resizable()
//                        .ignoresSafeArea()
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .aspectRatio(contentMode: .fill)
//                
//                        .opacity(0.1)
//                        .blur(radius: 10)
                }
                    .ignoresSafeArea()
              
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if (showDetailedProfile) {
                        Button(action: {
                            withAnimation(.easeIn) {
                                showDetailedProfile = false
                            }
                        }) {
                            Image(systemName: "xmark")
                               
                        }
                        .matchedGeometryEffect(id: "homeTool1", in: namespace)
                    }
                }
               
                ToolbarItem(placement: .topBarTrailing) {
                    if (!showDetailedProfile) {
                        Button(action: {
                            withAnimation(.easeIn) {
                                showFriendsList = true
                            }
                        }) {
                            Image(systemName: "person.3.fill")
                              
                        }
                        .matchedGeometryEffect(id: "homeTool1", in: namespace)
                    }
                }
            }
            .onAppear {
                EventSystem.shared.subscribe(AchievementsManager.shared, to: [PlayerActionEventType.buttonClick])
                
                showDetailedProfile = false
            }
            .fullScreenCover(isPresented: $showAchievements) {
                AchievementsView()
                    .presentationBackground(.bar)
                    .fadeIn()
            }
            .fullScreenCover(isPresented: $showLeaderboard) {
                LeaderboardView()
                    .presentationBackground(.bar)
                    .fadeIn()
            }
            .fullScreenCover(isPresented: $showStatictics) {
                StatisticsView()
                    .presentationBackground(.bar)
                    .fadeIn()
            }
            .fullScreenCover(isPresented: $showFriendsList) {
                FriendsListView()
                    .presentationBackground(.bar)
                    .fadeIn()
            }
        }
    }
}

#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        HomeNavigationStack()
            .environment(Friends.preview)
            .environment(Profile.preview)
            .environment(AchievementsProgression.preview)
            .environment(LeaderboardService.preview)
    }
}
