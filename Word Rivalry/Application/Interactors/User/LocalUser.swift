//
//  UsernameUpdate.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation
import CloudKit

/// `LocalUser` is a class responsible for managing the lifecycle and state of a user's profile within the application.
@Observable final class LocalUser: DataPreview {
    
    /// LocalUser Preview
    static var preview: LocalUser = {
        LocalUser.shared.user = .preview
        LocalUser.shared.isUserSet = true
        return LocalUser.shared
    }()
    
    /// Singleton pattern
    public static let shared = LocalUser()
    private init() {}
    
    /// Indicates whether the user profile has been successfully set.
    private(set) var isUserSet: Bool = false
    
    /// Holds the current user's data, initialized to a null user state.
    private(set) var user: User = .nullUser

    /// `userRepository` is an instance of `UserRepository` used to access and manipulate user data.
    private let userRepository: UserRepository = UserRepository()
    
    // MARK: - User Data Management

    /// Fetches the user's data primarily from the database, with a fallback to local storage on failure.
    /// This method sets up the user in the application if not already set, potentially assigning a unique username
    /// if it is a new user.
    ///
    /// ```swift
    ///     LocalUserInteractor.fetchUser()
    /// ```
    ///
    /// - Postcondition: The `user` property is updated to reflect the fetched or newly initialized user profile.
    /// - Throws: Propagates errors if both the database and local storage fetching fail, ensuring upstream handlers can react.
    public func fetchUser() async throws {
        var userTemp: User = try await userRepository.fetchUser()
        
        // Initialize a new user with a unique username if not already set.
        if isNewUser(for: user) {
            let username = try await generateUniqueName()
            userTemp.username = username
            userTemp = try await userRepository.saveUser(userTemp)
        }
        
        self.user = userTemp
        self.isUserSet = true
    }

    /// Generates a unique player name that does not exist in the database.
    /// Utilizes a loop to repeatedly generate names until a unique one is confirmed.
    /// - Returns: A `String` representing a unique player name.
    private func generateUniqueName() async throws -> String {
        var username = generateRandomName()
        
        while try await notUnique(username) {
            username = generateRandomName()
        }
        
        return username
    }
    
    /// Creates a random player name using the first 10 characters of a UUID, providing a simple method for generating potential unique identifiers.
    /// - Returns: A `String` consisting of the first 10 characters of a UUID.
    private func generateRandomName() -> String {
        String(UUID().uuidString.prefix(10))
    }
    
    /// Checks if a player name already exists in the database, ensuring player names are unique.
    /// - Parameter username: The username to check.
    /// - Returns: `true` if the username already exists; otherwise, `false`.
    /// - Throws: An error if the database query fails.
    private func notUnique(_ username: String) async throws -> Bool {
        return try await !userRepository.isUsernameUnique(username)
    }
    
    /// Checks if the user profile is essentially empty, used to determine if the user is new and requires initialization.
    /// - Parameter user: The `User` object to check.
    /// - Returns: `true` if the user's username field is empty, indicating a new, uninitialized user.
    private func isNewUser(for user: User) -> Bool {
        return user.username.isEmpty
    }
    
    // MARK: Username
    
    /// Updates the local user's username.
    ///
    /// ```swift
    ///     let newUsername = "Lighthouse"
    ///     LocalUserInteractor.updateUsername(with: newUsername)
    /// ```
    ///
    /// - Parameter username: The username to be set for the user.
    /// - Precondition: A validated username.
    /// - Postcondition: The  `User` object reflects the new username.
    /// - Throws: UserInteractorError.usernameTaken: if the requested username is already taken. Also, propagates other errors from the infrastructure layer related to fetching or updating data.
    public func updateUsername(with username: String) async throws -> Void {
        if !(try await userRepository.isUsernameUnique(username)) {
            throw UserInteractorError.usernameTaken
        }
        
        let user: User = try await userRepository.fetchUser()
        user.username = username
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: Country
    
    /// Updates the local user's country.
    ///
    /// ```swift
    ///     let country = Country.canada
    ///     LocalUserInteractor.updateCountry(with: country)
    /// ```
    ///
    /// - Parameter country: The country to be set for the user.
    /// - Postcondition: The  `User` object reflects the new country.
    /// - Throws: Propagates other errors from the infrastructure layer related to fetching or updating data.
    public func updateCountry(with country: Country) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.country = country
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: Title
    
    /// Updates the local user's title.
    ///
    /// ```swift
    ///     let title = Title.newLeaf
    ///     LocalUserInteractor.updateTitle(with: title)
    /// ```
    ///
    /// - Parameter title: The title to be set for the user.
    /// - Postcondition: The  `User` object reflects the new title.
    /// - Throws: Propagates other errors from the infrastructure layer related to fetching or updating data.
    public func updateTitle(with title: Title) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.title = title
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: Avatar
    
    /// Updates the local user's avatar.
    ///
    /// ```swift
    ///     let newAvatar = Avatar.default
    ///     LocalUserInteractor.updateAvatar(with: newAvatar)
    /// ```
    ///
    /// - Parameter avatar: The avatar to be set for the user.
    /// - Postcondition: The  `User` object reflects the new avatar.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func updateAvatar(with avatar: Avatar) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.avatar = avatar
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: PrimaryColor
    
    /// Updates the local user's primary color.
    ///
    /// ```swift
    ///     let newColor = "Blue"
    ///     LocalUserInteractor.updatePrimaryColor(with: newColor)
    /// ```
    ///
    /// - Parameter primaryColor: The primary color to be set for the user.
    /// - Postcondition: The  `User` object reflects the new primary color.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func updatePrimaryColor(with primaryColor: String) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.primaryColor = primaryColor
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: AvatarFrame
    
    /// Updates the local user's avatar frame.
    ///
    /// ```swift
    ///     let newFrame = AvatarFrame.gold
    ///     LocalUserInteractor.updateAvatarFrame(with: newFrame)
    /// ```
    ///
    /// - Parameter avatarFrame: The avatar frame to be set for the user.
    /// - Postcondition: The  `User` object reflects the new avatar frame.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func updateAvatarFrame(with avatarFrame: AvatarFrame) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.avatarFrame = avatarFrame
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: ProfileEffect
    
    /// Updates the local user's profile effect.
    ///
    /// ```swift
    ///     let newEffect = ProfileEffect.sparkles
    ///     LocalUserInteractor.updateProfileEffect(with: newEffect)
    /// ```
    ///
    /// - Parameter profileEffect: The profile effect to be set for the user.
    /// - Postcondition: The  `User` object reflects the new profile effect.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func updateProfileEffect(with profileEffect: ProfileEffect) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.profileEffect = profileEffect
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: AccentColor
    
    /// Updates the local user's accent color.
    ///
    /// ```swift
    ///     let newAccent = "Crimson"
    ///     LocalUserInteractor.updateAccent(with: newAccent)
    /// ```
    ///
    /// - Parameter accent: The accent color to be set for the user.
    /// - Postcondition: The  `User` object reflects the new accent color.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func updateAccent(with accent: String) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.accent = accent
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: AllTimePoints
    
    /// Updates the local user's all-time points.
    ///
    /// ```swift
    ///     LocalUserInteractor.increaseAllTimePoints(by: 100)
    /// ```
    ///
    /// - Parameter points: The points to be added to the user's all-time points.
    /// - Postcondition: The  `User` object reflects the new all-time points.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func increaseAllTimePoints(by points: Int) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.allTimePoints += max(0, points)  // Ensure only non-negative values are added
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: Experience
    
    /// Updates the local user's experience points.
    ///
    /// ```swift
    ///     LocalUserInteractor.increaseExperience(by: 50)
    /// ```
    ///
    /// - Parameter experience: The experience points to be added to the user's total.
    /// - Postcondition: The  `User` object reflects the new experience points.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func increaseExperience(by experience: Int) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.experience += max(0, experience)  // Ensure only non-negative values are added
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: SoloMatch
    
    /// Increments the count of solo matches.
    ///
    /// ```swift
    ///     LocalUserInteractor.incrementSoloMatch()
    /// ```
    ///
    /// - Postcondition: The  `User` object reflects the incremented solo match count.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func incrementSoloMatch() async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.soloMatch += 1
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: SoloWin
    
    /// Increments the count of solo wins.
    ///
    /// ```swift
    ///     LocalUserInteractor.incrementSoloWin()
    /// ```
    ///
    /// - Postcondition: The  `User` object reflects the incremented solo win count.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func incrementSoloWin() async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.soloWin += 1
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: TeamMatch
    
    /// Increments the count of team matches.
    ///
    /// ```swift
    ///     LocalUserInteractor.incrementTeamMatch()
    /// ```
    ///
    /// - Postcondition: The  `User` object reflects the incremented team match count.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func incrementTeamMatch() async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.teamMatch += 1
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: TeamWin
    
    /// Increments the count of team wins.
    ///
    /// ```swift
    ///     LocalUserInteractor.incrementTeamWin()
    /// ```
    ///
    /// - Postcondition: The  `User` object reflects the incremented team win count.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func incrementTeamWin() async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.teamWin += 1
        self.user = try await userRepository.saveUser(user)
    }
    
    // MARK: CurrentPoints
    
    /// Increases the local user's current points.
    ///
    /// ```swift
    ///     LocalUserInteractor.increaseCurrentPoints(by: 20)
    /// ```
    ///
    /// - Parameter points: The points to be added to the user's current points.
    /// - Postcondition: The  `User` object reflects the new current points.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    public func increaseCurrentPoints(by points: Int) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        user.currentPoints += max(0, points)  // Ensure only non-negative values are added
        self.user = try await userRepository.saveUser(user)
    }
    
    /// Decreases the local user's current points.
    ///
    /// ```swift
    ///     LocalUserInteractor.decreaseCurrentPoints(by: 15)
    /// ```
    ///
    /// - Parameter points: The points to be subtracted from the user's current points.
    /// - Throws: Propagates errors from the infrastructure layer related to fetching or updating data.
    /// - Note: This method does not allow the current points to go below zero.
    public func decreaseCurrentPoints(by points: Int) async throws -> Void {
        let user: User = try await userRepository.fetchUser()
        let decrementAmount = min(user.currentPoints, points)  // Prevent the points from going negative
        user.currentPoints -= decrementAmount
        self.user = try await userRepository.saveUser(user)
    }
}
