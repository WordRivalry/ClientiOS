//
//  UsernameUpdate.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation
import CloudKit
import OSLog

enum UserModificationError: Error, Equatable {
    static func == (lhs: UserModificationError, rhs: UserModificationError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
    
    case positiveNumberFound
    case negativeNumberFound
    case other(Error)
}

enum LocalUserModificationStatus<SuccessType> {
    case success(SuccessType)
    case failure(UserModificationError)
}

/// `LocalUser` is a class responsible for managing the lifecycle and state of a user's profile within the application.
/// - note: For Testing purposes. Use the userRepository which accepts a protocol. Pass in a Mock and TADA.
/// - warning: Use `LocalUser.shared.fetchUser` one time and check `isUserSet` before accessing the `user`.
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
    var userRepository: UserRepositoryProtocol = UserRepository()
    
    // MARK: - User Data Management
    
    /// Fetches the user's data primarily from the database, with a fallback to local storage on failure.
    /// This method sets up the user in the application if not already set, potentially assigning a unique username
    /// if it is a new user.
    ///
    /// ```swift 
    ///     LocalUser.shared.fetchUser()
    /// ```
    ///
    /// - Postcondition: The `user` property is updated to reflect the fetched or newly initialized user profile.
    /// - Throws: Propagates errors if both the database and local storage fetching fail, ensuring upstream handlers can react.
    public func fetchUser() async throws {
        self.user = try await userRepository.fetchLocalUser()
        self.isUserSet = true
        
        Logger.cloudKit.info("User is set : \(self.user.recordName)")
    }
    
    // MARK: Country
    
    /// Updates the local user's country and returns the updated value on success.
    ///
    /// This method fetches the current user, updates their country, and saves the updated user back to the repository. If successful, it updates the `user` property of `LocalUser` and returns the new country.
    ///
    /// Usage:
    /// ```swift
    /// let country = Country.canada
    /// let result = await LocalUser.shared.updateCountry(with: country)
    /// switch result {
    /// case .success(let updatedCountry):
    ///     print("Country updated to \(updatedCountry).")
    /// case .failure(let error):
    ///     print("Failed to update country: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter country: The country to be set for the user.
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the updated country on success.
    /// - Postcondition: If successful, the `User` object reflects the new country.
    @discardableResult
    public func updateCountry(
        with country: Country
    ) async -> LocalUserModificationStatus<Country> {
        do {
            let user: User = try await userRepository.fetchLocalUser()
            user.country = country
            self.user = try await userRepository.saveUser(user)
            return .success(self.user.country)
        } catch {
            return .failure(.other(error))
        }
    }
    
    // MARK: Title
    
    /// Updates the local user's title and returns the updated value on success.
    ///
    /// Usage:
    /// ```swift
    /// let result = await LocalUser.shared.updateTitle(with: .grandMaster)
    /// switch result {
    /// case .success(let updatedTitle):
    ///     print("Title updated to \(updatedTitle).")
    /// case .failure(let error):
    ///     print("Failed to update title: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter title: The title to be set for the user.
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the updated title on success.
    /// - Postcondition: If successful, the `User` object reflects the new title.
    @discardableResult
    public func updateTitle(
        with title: Title
    ) async -> LocalUserModificationStatus<Title> {
        do {
            let user: User = try await userRepository.fetchLocalUser()
            user.title = title
            self.user = try await userRepository.saveUser(user)
            return .success(self.user.title)
        } catch {
            return .failure(.other(error))
        }
    }
    
    // MARK: Avatar
    
    /// Updates the local user's avatar and returns the updated value on success.
    ///
    /// Usage:
    /// ```swift
    /// let result = await LocalUser.shared.updateAvatar(with: .warrior)
    /// switch result {
    /// case .success(let updatedAvatar):
    ///     print("Avatar updated to \(updatedAvatar).")
    /// case .failure(let error):
    ///     print("Failed to update avatar: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter avatar: The avatar to be set for the user.
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the updated avatar on success.
    /// - Postcondition: If successful, the `User` object reflects the new avatar.
    @discardableResult
    public func updateAvatar(
        with avatar: Avatar
    ) async -> LocalUserModificationStatus<Avatar> {
        do {
            let user: User = try await userRepository.fetchLocalUser()
            user.avatar = avatar
            self.user = try await userRepository.saveUser(user)
            return .success(self.user.avatar)
        } catch {
            return .failure(.other(error))
        }
    }
    
    // MARK: PrimaryColor
    
    /// Updates the local user's primary color and returns the updated color on success.
    ///
    /// Usage:
    /// ```swift
    /// let result = await LocalUser.shared.updatePrimaryColor(with: "Red")
    /// switch result {
    /// case .success(let updatedColor):
    ///     print("Primary color updated to \(updatedColor).")
    /// case .failure(let error):
    ///     print("Failed to update primary color: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter primaryColor: The primary color to be set for the user.
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the updated color on success.
    /// - Postcondition: If successful, the `User` object reflects the new primary color.
    @discardableResult
    public func updatePrimaryColor(
        with primaryColor: String
    ) async -> LocalUserModificationStatus<String> {
        do {
            let user: User = try await userRepository.fetchLocalUser()
            user.primaryColor = primaryColor
            self.user = try await userRepository.saveUser(user)
            return .success(self.user.primaryColor)
        } catch {
            return .failure(.other(error))
        }
    }
    
    // MARK: AvatarFrame
    
    /// Updates the local user's avatar frame and returns the updated frame on success.
    ///
    /// Usage:
    /// ```swift
    /// let result = await LocalUser.shared.updateAvatarFrame(with: .gold)
    /// switch result {
    /// case .success(let updatedFrame):
    ///     print("Avatar frame updated to \(updatedFrame).")
    /// case .failure(let error):
    ///     print("Failed to update avatar frame: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter avatarFrame: The avatar frame to be set for the user.
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the updated frame on success.
    /// - Postcondition: If successful, the `User` object reflects the new avatar frame.
    @discardableResult
    public func updateAvatarFrame(
        with avatarFrame: AvatarFrame
    ) async -> LocalUserModificationStatus<AvatarFrame> {
        do {
            let user: User = try await userRepository.fetchLocalUser()
            user.avatarFrame = avatarFrame
            self.user = try await userRepository.saveUser(user)
            return .success(self.user.avatarFrame)
        } catch {
            return .failure(.other(error))
        }
    }
    
    
    // MARK: ProfileEffect
    
    /// Updates the local user's profile effect and returns the updated effect on success.
    ///
    /// Usage:
    /// ```swift
    /// let result = await LocalUser.shared.updateProfileEffect(with: .sparkles)
    /// switch result {
    /// case .success(let updatedEffect):
    ///     print("Profile effect updated to \(updatedEffect).")
    /// case .failure(let error):
    ///     print("Failed to update profile effect: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter profileEffect: The profile effect to be set for the user.
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the updated profile effect on success.
    /// - Postcondition: If successful, the `User` object reflects the new profile effect.
    @discardableResult
    public func updateProfileEffect(
        with profileEffect: ProfileEffect
    ) async -> LocalUserModificationStatus<ProfileEffect> {
        do {
            let user: User = try await userRepository.fetchLocalUser()
            user.profileEffect = profileEffect
            self.user = try await userRepository.saveUser(user)
            return .success(self.user.profileEffect)
        } catch {
            return .failure(.other(error))
        }
    }
    
    
    // MARK: AccentColor
    
    /// Updates the local user's accent color and returns the updated color on success.
    ///
    /// Usage:
    /// ```swift
    /// let result = await LocalUser.shared.updateAccent(with: "Crimson")
    /// switch result {
    /// case .success(let updatedColor):
    ///     print("Accent color updated to \(updatedColor).")
    /// case .failure(let error):
    ///     print("Failed to update accent color: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter accent: The accent color to be set for the user.
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the updated accent color on success.
    /// - Postcondition: If successful, the `User` object reflects the new accent color.
    @discardableResult
    public func updateAccent(
        with accent: String
    ) async -> LocalUserModificationStatus<String> {
        do {
            let user: User = try await userRepository.fetchLocalUser()
            user.accent = accent
            self.user = try await userRepository.saveUser(user)
            return .success(self.user.accent)
        } catch {
            return .failure(.other(error))
        }
    }
    
    // MARK: SoloMatch
    
    /// Increments the count of solo matches and returns the updated count on success.
    ///
    /// Usage:
    /// ```swift
    /// let result = await LocalUser.shared.playedSoloMatch(didWin: true, stars: 100)
    /// switch result {
    /// case .success(let user):
    ///     print("Update for a solo match played.")
    /// case .failure(let error):
    ///     print("Failed to update for a solo match played: \(error)")
    /// }
    /// ```
    ///
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the incremented count on success.
    /// - Postcondition: The  `User` object reflects the incremented solo match count.
    @discardableResult
    public func playedSoloMatch(
        didWin: Bool,
        stars: Int
    ) async -> LocalUserModificationStatus<User> {
        do {
            let user: User = try await userRepository.fetchLocalUser()
            user.soloMatch += 1
            
            if didWin {
                user.soloWin += 1
                user.experience += 5
                user.currentPoints += stars
                user.allTimeStars += stars
            } else {
                user.experience += 2
            }
            
            self.user = try await userRepository.saveUser(user)
            return .success(self.user)
        } catch {
            return .failure(.other(error))
        }
    }
    
    // MARK: TeamMatch
    
    /// Increments the count of team matches and returns the updated count on success.
    ///
    /// Usage:
    /// ```swift
    /// let result = await LocalUser.shared.playedTeamMatch(didWin: true, stars: 100)
    /// switch result {
    /// case .success(let user):
    ///      print("Update for a team match played.")
    /// case .failure(let error):
    ///     print("Failed to update for a solo match played: \(error)")
    /// }
    /// ```
    ///
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the incremented count on success.
    /// - Postcondition: The  `User` object reflects the incremented team match count.
    @discardableResult
    public func playedTeamMatch(
        didWin: Bool, 
        stars: Int
    ) async -> LocalUserModificationStatus<User> {
        do {
            let user: User = try await userRepository.fetchLocalUser()
            
            user.teamMatch += 1

            if didWin {
                user.teamWin += 1
                user.experience += 5
                user.currentPoints += stars
                user.allTimeStars += stars
            } else {
                user.experience += 2
            }
            
            self.user = try await userRepository.saveUser(user)
            return .success(self.user)
        } catch {
            return .failure(.other(error))
        }
    }
    
    // MARK: CurrentPoints
 
    /// Decreases the local user's current points and returns the updated total on success.
    ///
    /// Usage:
    /// ```swift
    /// let result = await LocalUser.shared.decreaseCurrentPoints(by: 15)
    /// switch result {
    /// case .success(let newTotal):
    ///     print("Current points decreased to \(newTotal).")
    /// case .failure(let error):
    ///     print("Failed to decrease current points: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter points: The points to be subtracted from the user's current points. Must be non-negative.
    /// - Returns: A `LocalUserModificationStatus` indicating the outcome of the operation, carrying the new total points on success.
    /// - Postcondition: If successful, the `User` object reflects the new current points. This method does not allow the current points to go below zero.
    @discardableResult
    public func decreaseStars(by points: Int) async -> LocalUserModificationStatus<Int> {
        
        guard points >= 0 else { return .failure(.negativeNumberFound) }
        
        do {
            let user: User = try await userRepository.fetchLocalUser()
            
            let decrementAmount = min(user.currentPoints, points) // Prevent below zero
            user.currentPoints -= decrementAmount
         
            self.user = try await userRepository.saveUser(user)
            return .success(self.user.currentPoints)
        } catch {
            return .failure(.other(error))
        }
    }
}
