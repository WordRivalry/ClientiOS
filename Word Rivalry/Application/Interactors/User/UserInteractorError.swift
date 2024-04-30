//
//  PublicProfileUCError.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

enum UserInteractorError: Error {
    case userDataFound
    case invalidDataType
    case usernameTaken
}
