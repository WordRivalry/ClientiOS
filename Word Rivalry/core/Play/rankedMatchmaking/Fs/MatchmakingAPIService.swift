//
//  MatchmakingAPIService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-04.
//

import Foundation

class MatchmakingAPIService {
//    func searchMatch(matchmakingType: MatchmakingType, completion: @escaping (Result<Bool, Error>) -> Void) {
//        // Simulate network request with a delay
//        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//            // Simulate a successful search result
//            completion(.success(true))
//        }
//    }
    
    func cancelSearch(completion: @escaping (Result<Bool, Error>) -> Void) {
        // Simulate cancelling the search request
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // Simulate a successful cancellation
            completion(.success(true))
        }
    }
}

