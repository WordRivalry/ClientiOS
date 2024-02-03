//
//  FriendsListView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct FriendsListView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ScrollView {
            Text("Friend 1")
                .glassed()
            Text("Friend 2")
                .glassed()
            Text("Friend 3")
                .glassed()
        }
        .onTapGesture {
            dismiss()
        }
    }
}


#Preview {
    FriendsListView()
}
