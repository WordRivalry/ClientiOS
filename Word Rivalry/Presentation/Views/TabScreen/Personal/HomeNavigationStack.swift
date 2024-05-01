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
    @State private var showSettings = false
    
    init() {
        Logger.viewCycle.debug("~~~ HomeNavigationStack init ~~~")
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Divider()
                    Text("General")
                        .padding(.horizontal)
                        .font(.title)
                    HStack {
                        Text("Experience : ")
                        Text("\(localUser.user.experience)")
                    }
                    Divider()
                    Text("All time")
                        .padding(.horizontal)
                        .font(.title)
                    HStack {
                        Text("Points : ")
                        Text("\(localUser.user.allTimePoints)")
                    }
                    HStack {
                        Text("Solo match : ")
                        Text("\(localUser.user.soloMatch)")
                    }
                    HStack {
                        Text("Solo win : ")
                        Text("\(localUser.user.soloWin)")
                    }
                    HStack {
                        Text("Team match : ")
                        Text("\(localUser.user.teamMatch)")
                    }
                    HStack {
                        Text("Team win : ")
                        Text("\(localUser.user.teamWin)")
                    }
                }
                .padding(.horizontal)
            }
            .infinityFrame()
            .background {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .foregroundStyle(.bar)
            }
            .ignoresSafeArea()
            .navigationTitle("Career")
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
            .sheet(isPresented: $showSettings) {
                
            } content: {
                SettingsView()
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
