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
    private var mockUserProfileService: UserProfileService!
    
    override func setUp() {
        super.setUp()
        self.mockAPIClient = MockTechTrainAPIClient()
        self.mockUserProfileService = UserProfileService(apiClient: self.mockAPIClient)
    }
    
    override func tearDown() {
        mockAPIClient = nil
        mockUserProfileService = nil
        super.tearDown()
    }
    
    // MARK: - updateUserName
    func testUpdateAndSetUserNameSuccess() async throws {
        let testToken = "test-token"
        let enteredNewName = "NewUserName"
        // 変更前アカウントを設定
        await self.mockUserProfileService.updateAccountState(newState: TBRUser(token: testToken, name: "Unknown"))
        // レスポンスデータを設定
        let responseDict: [String: String] = ["name": "NewUserName"]
        let responseData = try? JSONSerialization.data(withJSONObject: responseDict, options: [])
        await mockAPIClient.setResponseData(responseData)
        // Act
        try await self.mockUserProfileService.updateAndSetUserName(withToken: testToken, enteredNewName: enteredNewName)
        // Assert
        let nameResult = await mockUserProfileService.getAccountData()?.name
        XCTAssertEqual(nameResult, enteredNewName)
    }
    
    func testUpdateAndSetUserNameFailure() async {
        // Arrange
        let testToken = "test-token"
        let enteredNewName = "NewUserName"
        await self.mockUserProfileService.updateAccountState(newState: TBRUser(token: testToken, name: enteredNewName))
        await mockAPIClient.setShouldThrowError(true) // Simulate an error
        // Act & Assert
        do {
            try await self.mockUserProfileService.fetchUserProfileAndSetSelfAccount(withToken: testToken)
            XCTFail("Expected an error to be thrown")
        } catch {
            // Success
        }
    }
    
    // MARK: - fetchUserProfileAndSetSelfAccount
    func testFetchUserProfileAndSetSelfAccountSuccess() async throws {
        let testToken = "test-token"
        // レスポンスデータを設定
        let responseDict: [String: String] = ["name": "Test User","iconUrl": "https://example.com/icon.png"]
        let responseData = try? JSONSerialization.data(withJSONObject: responseDict, options: [])
        await mockAPIClient.setResponseData(responseData)
        // Act
        try await self.mockUserProfileService.fetchUserProfileAndSetSelfAccount(withToken: testToken)
        // Assert
        let accountData = await self.mockUserProfileService.getAccountData()
        XCTAssertNotNil(accountData)
        XCTAssertEqual(accountData?.name, "Test User")
        XCTAssertEqual(accountData?.iconUrl, "https://example.com/icon.png")
    }
    
    func testFetchUserProfileAndSetSelfAccountFailure() async throws {
        // Arrange
        let testToken = "test-token"
        await mockAPIClient.setShouldThrowError(true)
        // Act & Assert
        do {
            try await self.mockUserProfileService.fetchUserProfileAndSetSelfAccount(withToken: testToken)
            XCTFail("Expected an error to be thrown")
        } catch {
            // Success
        }
    }
}
