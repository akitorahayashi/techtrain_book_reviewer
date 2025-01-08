//
//  UserProfileServiceTests.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/07.
//

import XCTest
@testable import techtrain_book_reviewer

final class UserProfileServiceTests: XCTestCase {
    private var mockAPIClient: MockTechTrainAPIClient!
    private var userProfileService: UserProfileService!
    
    override func setUp() {
        super.setUp()
        self.mockAPIClient = MockTechTrainAPIClient()
        self.userProfileService = UserProfileService(apiClient: self.mockAPIClient)
    }
    
    override func tearDown() {
        mockAPIClient = nil
        userProfileService = nil
        super.tearDown()
    }
    
    func testUpdateUserNameSuccess() async throws {
        let token = "test-token"
        let newName = "NewUserName"
        await mockAPIClient.setResponseData(Data())
        
//        try await self.userProfileService.updateUserName(withToken: token, newName: newName)
//        
//        XCTAssertEqual(UserProfileService.yourAccount?.name, newName)
    }
}
