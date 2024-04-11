//
//  FriendsListView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct FriendsListView: View {
    @Environment(Friends.self) private var friends: Friends
    
    // Local state to store fetched profiles
    @State private var profiles: [PublicProfile] = []
    
    var body: some View {
        VStack {
            header
            ScrollView {
                LazyVStack {
                    ForEach(profiles.indices, id: \.self) { index in
                        FriendListRow(profile: profiles[index])
                            .padding(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollContentBackground(.hidden)
            .onAppear {
                fetchProfiles()
            }
            Spacer()
            BasicDissmiss()
        }
    }
    
    
    @ViewBuilder
    private var header: some View {
        Text("Friends")
            .font(.largeTitle)
    }
    
    private func fetchProfiles() {
        let recordIDs = friends.friends.map { $0.friendRecordID }
        Task {
            do {
                let fetchedProfiles = try await PublicDatabase.shared.fetchManyPublicProfiles(forUserRecordIDs: recordIDs)
                
                if (friends.friends.count != fetchedProfiles.count) {
                    profiles = [
                        PublicProfile(userRecordID: "234234234", playerName: "Player 1"),
                        PublicProfile(userRecordID: "234234234", playerName: "Player 2"),
                        PublicProfile(userRecordID: "234234234", playerName: "Player 3"),
                        PublicProfile(userRecordID: "234234234", playerName: "Player 4"),
                        PublicProfile(userRecordID: "234234234", playerName: "Player 5"),
                    ]
                } else {
                    profiles = fetchedProfiles
                }
        
            } catch {
                print("Error fetching profiles: \(error)")
            }
        }
    }
}


#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        FriendsListView()
            .environment(Friends.preview)
    }
}
