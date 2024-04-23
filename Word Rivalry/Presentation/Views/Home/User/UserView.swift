//
//  UserView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import SwiftUI

struct UserView: View {
    @State var viewModel: UserViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let user = viewModel.user {
                Text("Welcome, \(user.playerName)")
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            viewModel.fetchUser()
        }
    }
}

#Preview {
    UserView(viewModel: UserViewModel())
}
