//
//  UserRepositoryTests.swift
//  Word RivalryTests
//
//  Created by benoit barbier on 2024-05-07.
//

import XCTest
@testable import Word_Rivalry
import CloudKit

final class UserRepositoryTests: XCTestCase {
    
    var mockDatabase: MockCloudKitManager!
    var userRepository: UserRepository!

    override func setUp() {
        super.setUp()
        
        mockDatabase = MockCloudKitManager()
        
        let userIDs = ["user5", "user2", "user3", "user4"]
        mockDatabase.storage[String(describing: User.self)] = userIDs.map( { id in User(userID: id)
        })
        
        userRepository = UserRepository(db: mockDatabase)
    }
    
    func testFetchAnyUserSuccess() async throws {
        // Execute
        let fetchedUser = try await userRepository.fetchAnyUser(by: "user2")
        
        // Verify
        XCTAssertEqual(fetchedUser.userID, "user2")
    }
    
    func testFetchAnyUserFailure() async throws {
        // Setup failure mode
        mockDatabase.shouldReturnFailure = true
        
        do {
            // Execute
            let _ = try await userRepository.fetchAnyUser(by: "NA")
            XCTFail("Should have thrown an error but did not")
        } catch {
            // Verify error type or message if specific
            
            XCTAssertTrue(error is NSError)
        }
    }
    
    override func tearDown() {
        mockDatabase = nil
        userRepository = nil
        super.tearDown()
    }
}

