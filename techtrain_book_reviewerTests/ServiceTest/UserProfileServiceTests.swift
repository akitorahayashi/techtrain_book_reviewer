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
    private var userProfileServiceWithMock: UserProfileService!
    
    override func setUp() {
        super.setUp()
        self.mockAPIClient = MockTechTrainAPIClient()
        self.userProfileServiceWithMock = UserProfileService(apiClient: self.mockAPIClient)
    }
    
    override func tearDown() {
        mockAPIClient = nil
        userProfileServiceWithMock = nil
        super.tearDown()
    }
    
    func testUpdateUserNameSuccess() async throws {
        let testToken = "test-token"
        let enteredNewName = "NewUserName"
        // レスポンスデータを設定
        let responseDict: [String: String] = ["name": "NewUserName"]
        let responseData = try? JSONSerialization.data(withJSONObject: responseDict, options: [])
        await mockAPIClient.setResponseData(responseData)
        // 変更前アカウントを設定
        await self.userProfileServiceWithMock.updateAccountState(newState: TBRUser(token: testToken, name: "Unknown"))
        // Act
        try await self.userProfileServiceWithMock.updateAndSetUserName(withToken: testToken, enteredNewName: enteredNewName)
        // Assert
        let nameResult = await userProfileServiceWithMock.getAccountData()?.name
        XCTAssertEqual(nameResult, enteredNewName)
    }
    
    func testFetchUserProfileAndSetSelfAccountSuccess() async throws {
        let testToken = "test-token"
        // レスポンスデータを設定
        let responseDict: [String: String] = ["name": "Test User","iconUrl": "https://example.com/icon.png"]
        let responseData = try? JSONSerialization.data(withJSONObject: responseDict, options: [])
        await mockAPIClient.setResponseData(responseData)
        // Act
        try await self.userProfileServiceWithMock.fetchUserProfileAndSetSelfAccount(withToken: testToken)
        // Assert
        let accountData = await self.userProfileServiceWithMock.getAccountData()
        XCTAssertNotNil(accountData)
        XCTAssertEqual(accountData?.name, "Test User")
        XCTAssertEqual(accountData?.iconUrl, "https://example.com/icon.png")
    }
}
