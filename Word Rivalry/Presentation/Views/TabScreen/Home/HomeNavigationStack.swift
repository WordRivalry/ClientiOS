//
//  HomeNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import OSLog

struct HomeNavigationStack: View {
    @Environment(LocalUser.self) private var localUser
    
    @Namespace private var namespace
    
    @State private var showDetailedProfile = false
    @State private var showFriendsList = false
    @State private var showLeaderboard = false
    @State private var showAchievements = false
    
    init() {
        Logger.viewCycle.debug("~~~ HomeNavigationStack init ~~~")
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
                }
            }
            .navigationTitle(localUser.user.username)
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
            .fullScreenCover(isPresented: $showLeaderboard) {
                LeaderboardView()
                    .presentationBackground(.bar)
                    .fadeIn()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
//                    ZStack {
//                        // Capsule shape simulating the cylinder
//                        Capsule()
//                            .fill(.accent.opacity(0.5))
//                            .frame(width: 100, height: 30)
//                        
//                        HStack {
//                            Image("currency")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30, height: 30)
//                            
//                            // Text positioned above the capsule
//                            Text("\(localUser.user.currentPoints)")
//                                .foregroundColor(.white)
//                                .font(.title3)
//                        }
//                    }
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
