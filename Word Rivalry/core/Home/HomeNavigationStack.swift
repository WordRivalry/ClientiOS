//
//  HomeNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import GameKit

struct HomeNavigationStack: View {
    @Environment(PublicProfile.self) private var profile: PublicProfile
    @Namespace private var namespace
    
    @State private var showDetailedProfile = false
    @State private var showFriendsList = false
    @State private var showLeaderboard = false
    @State private var showAchievements = false
    @State private var showStatictics = false
    
    init() {
        debugPrint("~~~ HomeNavigationStack init ~~~")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    ProfileCardView(namespace: namespace)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                showDetailedProfile = true
                            }
                        }
                        .padding(.bottom)
                        .padding(.bottom)
                    
                    BasicButton(text: "Leaderboard") {
                        showLeaderboard = true
                    }
                    .matchedGeometryEffect(id: "button0", in: namespace)
                    
                    BasicButton(text: "Statistics") {
                        showStatictics = true
                    }
                    .matchedGeometryEffect(id: "button1", in: namespace)
                }
            }
            .navigationTitle(profile.playerName)
            .navigationBarTitleDisplayMode(.automatic)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                showDetailedProfile = false
            }
            .background(
                Image("bg")
                    .resizable()
                    .ignoresSafeArea()
            )
            .fullScreenCover(isPresented: $showDetailedProfile) {
                EditableProfileCardView(
                    namespace: namespace
                )
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
                ToolbarItem(placement: .principal) {
                    ZStack {
                        // Capsule shape simulating the cylinder
                        Capsule()
                            .fill(.accent.opacity(0.5))
                            .frame(width: 100, height: 30)
                        
                        HStack {
                            Image("currency")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            
                            // Text positioned above the capsule
                            Text("233")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }
                }
            }
        }
        .logLifecycle(viewName: "HomeNavigationStack")
    }
}

#Preview {
    ViewPreview {
        HomeNavigationStack()
    }
}
