//
//  LocalUserTests.swift
//  Word RivalryTests
//
//  Created by benoit barbier on 2024-05-05.
//

import XCTest
@testable import Word_Rivalry

private let LOCAL_USER_ID = "local-user-id"

class MockUserRepository: UserRepositoryProtocol {
    // Simulating in-memory storage to mimic database interactions
    private var localStore: [String: User] = [:]
    
    // This user ID represents the 'local' user in this context.
    private let localUserID = LOCAL_USER_ID
    
    // Error simulation flags
    var fetchLocalUserThrowsError: Bool = false
    var saveUserThrowsError: Bool = false
    var fetchAnyUserThrowsError: Bool = false
    
    // Fetch if exist, else create it and return it
    func fetchLocalUser() async throws -> User {
        
        if fetchLocalUserThrowsError {
            throw NSError()
        }
        
        if let user = localStore[localUserID] {
            return user
        } else {
            let user: User = .init(userID: localUserID)
            return user
        }
    }
    
    func fetchAnyUser(by userID: String) async throws -> User {
        if let user = localStore[userID] {
            return user
        } else {
            throw NSError(domain: "UserNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
    }
    
    func saveUser(_ user: User) async throws -> User {
        localStore[user.userID] = user
        return user
    }
    
    // Helper function to set initial state for tests
    func populateInitialUser(user: User) {
        localStore[user.userID] = user
    }
    
    // Helper function to clear the storage for clean state tests
    func clearLocalStorage() {
        localStore.removeAll()
    }
}

final class LocalUserTests: XCTestCase {
    var localUser: LocalUser!
    var mockUserRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        localUser = LocalUser.shared
        localUser.userRepository = mockUserRepository
    }
    
    override func tearDown() {
        localUser = nil
        mockUserRepository.clearLocalStorage()
        super.tearDown()
    }
    
    func testFetchUserWithCreation() async throws {
        // Since no user is initially set, this should trigger user creation
        try await localUser.fetchUser()
        
        XCTAssertTrue(localUser.isUserSet)
        XCTAssertEqual(localUser.user.userID, LOCAL_USER_ID)
     
    }
    
    func testFetchUserSuccess() async throws {
        // Setup an initial user in the local store
        let initialUser = User(userID: LOCAL_USER_ID)
        mockUserRepository.populateInitialUser(user: initialUser)
        
        try await localUser.fetchUser()
        
        XCTAssertTrue(localUser.isUserSet)
        XCTAssertEqual(localUser.user.userID, initialUser.userID)
    }
    
    
    // MARK: Country Update
    func testUpdateCountrySuccess() async {
        // Test each country available in the enumeration.
        for country in Country.allCases {
            let result = await localUser.updateCountry(with: country)
            
            switch result {
            case .success(let updatedCountry):
                XCTAssertEqual(updatedCountry, country, "Country should match '\(country)' after update.")
                XCTAssertEqual(localUser.user.country, country, "The user's country property should be updated to '\(country)'.")
            case .failure(let userModificationError):
                XCTFail("Expected successful country update for '\(country)' but got a failure: \(userModificationError)")
            }
        }
    }

    
    // MARK: Tile Update
    func testUpdateTitleSuccess() async {
        // Test each title available in the enumeration.
        for title in Title.allCases {
            let result = await localUser.updateTitle(with: title)
            
            switch result {
            case .success(let updatedTitle):
                XCTAssertEqual(updatedTitle, title, "Title should match '\(title)' after update.")
                XCTAssertEqual(localUser.user.title, title, "The user's title property should be updated to '\(title)'.")
            case .failure(let userModificationError):
                XCTFail("Expected successful title update for '\(title)' but got a failure: \(userModificationError)")
            }
        }
    }

    
    // MARK: Avatar Update
    func testUpdateAvatarSuccess() async {
        // Test each avatar available in the enumeration.
        for avatar in Avatar.allCases {
            let result = await localUser.updateAvatar(with: avatar)
            
            switch result {
            case .success(let updatedAvatar):
                XCTAssertEqual(updatedAvatar, avatar, "Avatar should match '\(avatar)' after update.")
                XCTAssertEqual(localUser.user.avatar, avatar, "The user's avatar property should be updated to '\(avatar)'.")
            case .failure(let userModificationError):
                XCTFail("Expected successful avatar update for '\(avatar)' but got a failure: \(userModificationError)")
            }
        }
    }

    // MARK: PrimaryColor Update

    func testUpdatePrimaryColorSuccess() async {
        let colors = ["Red", "Blue", "Green", "Yellow"]  // Example color set
        for color in colors {
            let result = await localUser.updatePrimaryColor(with: color)
            
            switch result {
            case .success(let updatedColor):
                XCTAssertEqual(updatedColor, color, "Primary color should match \(color) after update.")
                XCTAssertEqual(localUser.user.primaryColor, color, "The user's primary color property should be updated to \(color).")
            case .failure(let error):
                XCTFail("Failed to update primary color to \(color): \(error)")
            }
        }
    }

    // MARK: AvatarFrame Update
    
    func testUpdateAvatarFrameSuccess() async {
        for frame in AvatarFrame.allCases {
            let result = await localUser.updateAvatarFrame(with: frame)
            
            switch result {
            case .success(let updatedFrame):
                XCTAssertEqual(updatedFrame, frame, "Avatar frame should match \(frame) after update.")
                XCTAssertEqual(localUser.user.avatarFrame, frame, "The user's avatar frame property should be updated to \(frame).")
            case .failure(let error):
                XCTFail("Failed to update avatar frame to \(frame): \(error)")
            }
        }
    }

    
    // MARK: ProfileEffect Update
    
    func testUpdateProfileEffectSuccess() async {
        for effect in ProfileEffect.allCases {
            let result = await localUser.updateProfileEffect(with: effect)
            
            switch result {
            case .success(let updatedEffect):
                XCTAssertEqual(updatedEffect, effect, "Profile effect should match \(effect) after update.")
                XCTAssertEqual(localUser.user.profileEffect, effect, "The user's profile effect property should be updated to \(effect).")
            case .failure(let error):
                XCTFail("Failed to update profile effect to \(effect): \(error)")
            }
        }
    }

    // MARK: AccentColor Update
    
    func testUpdateAccentColorSuccess() async {
        let accents = ["Crimson", "Magenta", "Azure", "Gold"]  // Example accent set
        for accent in accents {
            let result = await localUser.updateAccent(with: accent)
            
            switch result {
            case .success(let updatedAccent):
                XCTAssertEqual(updatedAccent, accent, "Accent color should match \(accent) after update.")
                XCTAssertEqual(localUser.user.accent, accent, "The user's accent color property should be updated to \(accent).")
            case .failure(let error):
                XCTFail("Failed to update accent color to \(accent): \(error)")
            }
        }
    }

    
    // MARK: SoloWin Update
    
    func testIncrementSoloWinSuccess() async {
        let initialWins = localUser.user.soloWin
        let result = await localUser.incrementSoloWin()

        switch result {
        case .success(let updatedWins):
            XCTAssertEqual(updatedWins, initialWins + 1, "Solo win count should increment by 1.")
            XCTAssertEqual(localUser.user.soloWin, updatedWins, "The user's solo win count should reflect the incremented value.")
        case .failure(let error):
            XCTFail("Failed to increment solo win count: \(error)")
        }
    }

    
    // MARK: SoloMatch Update
    
    func testIncrementSoloMatchSuccess() async {
        let initialCount = localUser.user.soloMatch
        let result = await localUser.incrementSoloMatch()

        switch result {
        case .success(let updatedCount):
            XCTAssertEqual(updatedCount, initialCount + 1, "Solo match count should increment by 1.")
            XCTAssertEqual(localUser.user.soloMatch, updatedCount, "The user's solo match count should reflect the incremented value.")
        case .failure(let error):
            XCTFail("Failed to increment solo match count: \(error)")
        }
    }

    
    // MARK: TeamMatch Update
    
    func testIncrementTeamMatchSuccess() async {
        let initialMatches = localUser.user.teamMatch
        let result = await localUser.incrementTeamMatch()

        switch result {
        case .success(let updatedMatches):
            XCTAssertEqual(updatedMatches, initialMatches + 1, "Team match count should increment by 1.")
            XCTAssertEqual(localUser.user.teamMatch, updatedMatches, "The user's team match count should reflect the incremented value.")
        case .failure(let error):
            XCTFail("Failed to increment team match count: \(error)")
        }
    }

    
    // MARK: TeamWin Update
    
    func testIncrementTeamWinSuccess() async {
        let initialWins = localUser.user.teamWin
        let result = await localUser.incrementTeamWin()

        switch result {
        case .success(let updatedWins):
            XCTAssertEqual(updatedWins, initialWins + 1, "Team win count should increment by 1.")
            XCTAssertEqual(localUser.user.teamWin, updatedWins, "The user's team win count should reflect the incremented value.")
        case .failure(let error):
            XCTFail("Failed to increment team win count: \(error)")
        }
    }
    

    // MARK:  AllTimePoints Updates
    
    func testIncreaseAllTimePointsSuccess() async throws {
        // Test for a valid non-negative input.
        let increaseAmount = 100
        
        // Make sure the user is set
        try await localUser.fetchUser()
        
        // Current Value
        let currentAllTimePoints = localUser.user.allTimeStars
        
        // Expected Value
        let expected = currentAllTimePoints + increaseAmount
        
        // Execute
        let result = await localUser.increaseAllTimePoints(by: increaseAmount)

        // Check
        switch result {
        case .success(let newTotal):
            XCTAssertEqual(newTotal, expected, "AllTimePoints should match \(expected) after update.")
            
            XCTAssertEqual(localUser.user.allTimeStars, expected, "The user's allTimePoints property should be updated to \(expected).")
        case .failure(let error):
            XCTFail("Failed to update all-time points: \(error)")
        }
    }

    func testIncreaseAllTimePointsFailure() async {
        // Test for a negative input.
        let result = await localUser.increaseAllTimePoints(by: -1)

        switch result {
        case .success:
            XCTFail("Should have failed due to negative increment")
        case .failure(let error):
            XCTAssertEqual(error, .negativeNumberFound)
            print("Correctly failed to update all-time points with negative input.")
        }
    }
    
    
    // MARK:  Experience Updates
    
    func testIncreaseExperienceSuccess() async throws {
        // Test for a valid non-negative input.
        let increaseAmount = 50
        
        // Make sure the user is set
        try await localUser.fetchUser()
        
        // Current Value
        let currentExperience = localUser.user.experience
        
        // Expected Value
        let expected = currentExperience + increaseAmount
        
        // Execute
        let result = await localUser.increaseExperience(by: increaseAmount)

        //  Check
        switch result {
        case .success(let newTotal):
            
            XCTAssertEqual(newTotal, expected, "Experience should match \(expected) after update.")
            
            XCTAssertEqual(localUser.user.experience, expected, "The user's experience property should be updated to \(expected).")
        case .failure(let error):
            XCTFail("Failed to update experience: \(error)")
        }
    }

    func testIncreaseExperienceFailure() async {
        let result = await localUser.increaseExperience(by: -50)

        switch result {
        case .success:
            XCTFail("Should have failed due to negative increment")
        case .failure(let error):
            XCTAssertEqual(error, .negativeNumberFound)
            print("Correctly failed to update experience with negative input.")
        }
    }

    // MARK:  CurrentPoints Updates

    func testIncreaseCurrentPointsSuccess() async {
        let increaseAmount = 20
        let result = await localUser.increaseCurrentPoints(by: increaseAmount)

        switch result {
        case .success(let newTotal):
            XCTAssertEqual(newTotal, localUser.user.currentPoints)
            print("Current points successfully updated to \(newTotal).")
        case .failure(let error):
            XCTFail("Failed to increase current points: \(error)")
        }
    }

    func testIncreaseCurrentPointsFailure() async {
        let result = await localUser.increaseCurrentPoints(by: -20)

        switch result {
        case .success:
            XCTFail("Should have failed due to negative increment")
        case .failure(let error):
            XCTAssertEqual(error, .negativeNumberFound)
            print("Correctly failed to increase current points with negative input.")
        }
    }
    
    func testDecreaseCurrentPointsSuccess() async {
        localUser.user.currentPoints = 20
        
        // Assuming initial current points are greater than 15 for this test.
        let decreaseAmount = 15
        let result = await localUser.decreaseStars(by: decreaseAmount)

        switch result {
        case .success(let newTotal):
            XCTAssertEqual(newTotal, localUser.user.currentPoints)
            print("Current points successfully decreased to \(newTotal).")
        case .failure(let error):
            XCTFail("Failed to decrease current points: \(error)")
        }
    }

    func testDecreaseCurrentPointsFailure() async {
        let result = await localUser.decreaseStars(by: -15)  // Negatice number should fail

        switch result {
        case .success:
            XCTFail("Should have failed due to negative decrement. Decrement is negatif intrinsically.")
        case .failure(let error):
            XCTAssertEqual(error, .negativeNumberFound)
            print("Correctly failed to decrease current points with negative input.")
        }
    }
}
