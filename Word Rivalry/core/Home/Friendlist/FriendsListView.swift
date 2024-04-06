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
    @State private var profiles: [Profile] = []
    
    var body: some View {
        VStack {
            List(profiles, id: \.userRecordID) { profile in
                HStack {
                    PortraitView(profileImage: profile.profileImage, banner: profile.banner)
                        .scaleEffect(0.4)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.playerName)
                            .font(.headline)
                        Text("Elo \(profile.eloRating)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
         //   .environment(\.defaultMinListRowHeight, 70)
            .scrollContentBackground(.hidden)
            .onAppear {
                fetchProfiles()
            }
            
            Spacer()
            BasicDissmiss()
        }
    }
    
    private func fetchProfiles() {
        let recordIDs = friends.friends.map { $0.friendRecordID }
        Task {
            do {
                let fetchedProfiles = try await PublicDatabase.shared.fetchManyProfiles(forUserRecordIDs: recordIDs)
                
                if (friends.friends.count != fetchedProfiles.count) {
                    profiles = [
                        Profile(userRecordID: "234234234", playerName: "Player 1"),
                        Profile(userRecordID: "234234234", playerName: "Player 2"),
                        Profile(userRecordID: "234234234", playerName: "Player 3"),
                        Profile(userRecordID: "234234234", playerName: "Player 4"),
                        Profile(userRecordID: "234234234", playerName: "Player 5"),
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
