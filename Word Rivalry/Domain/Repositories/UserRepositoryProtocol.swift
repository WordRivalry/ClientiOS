//
//  UserRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchUser() async throws -> User
    func fetchUser(by username: String) async throws -> User
    func isUserNew() async throws -> Bool
    func saveUser(_: User) async throws -> User
    func isUsernameUnique(_ playerName: String) async throws -> Bool
}
