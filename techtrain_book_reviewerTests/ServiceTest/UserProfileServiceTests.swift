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
        let token = "test-token"
        let enteredNewName = "NewUserName"
        let responseDict: [String: String] = ["name": "NewUserName"]
        let responseData = try? JSONSerialization.data(withJSONObject: responseDict, options: [])
        // レスポンスデータを設定
        await mockAPIClient.setResponseData(responseData)
        // アカウントを設定
        await self.userProfileServiceWithMock.updateAccountState(newState: TBRUser(token: "sample", name: "Unknown"))
        // Action
        try await self.userProfileServiceWithMock.updateAndSetUserName(withToken: token, enteredNewName: enteredNewName)
        // Check
        let nameResult = await userProfileServiceWithMock.getAccountData()?.name
        // 更新されたユーザー名を検証
        XCTAssertEqual(nameResult, enteredNewName)
    }

}
