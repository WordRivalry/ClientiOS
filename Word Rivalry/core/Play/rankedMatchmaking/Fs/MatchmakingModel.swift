//
//  MatchmakingModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-04.
//

import SwiftUI
import Combine

@Observable class MatchmakingViewModel: ObservableObject {
    var process: MatchmakingProcess = .searching
    
    private let service = MatchmakingAPIService()
    var matchmakingType: MatchmakingType = .normal
    var cancellables = Set<AnyCancellable>()
    
    func searchMatch() {
        process = .searching
        service.searchMatch(matchmakingType: matchmakingType) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Transition to countdown upon successful search
                    self?.process = .countdown(3)
                case .failure(let error):
                    // Handle error scenario, perhaps updating process to reflect an error state
                    print("Error searching for match: \(error)")
                }
            }
        }
    }
    
    func cancelSearch() {
        service.cancelSearch { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Handle search cancellation, perhaps dismissing the full screen cover
                    self?.process = .searching // Resetting the process or setting to a specific state
                case .failure(let error):
                    // Handle error scenario
                    print("Error cancelling search: \(error)")
                }
            }
        }
    }
}

