//
//  UserViewModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-23.
//

import Foundation

@Observable final class UserViewModel {
    var user: User?
    var error: Error?
    var isLoading: Bool = false

    // Use case
    private let fetchLocalUser = FetchLocalUser()
    
    init() {}
    
    func fetchUser() {
        Task {
            
            // UI Error Reset
            await MainActor.run {
                self.error = nil
                self.isLoading = true
            }
            
            do {
                // Work
                let tempUser = try await fetchLocalUser.execute()
                    
                // UI
                await MainActor.run {
                    self.user = tempUser
                    self.isLoading = false
                }
            } catch {
                
                // UI
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}
