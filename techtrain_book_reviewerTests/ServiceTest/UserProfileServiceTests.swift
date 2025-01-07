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
        userProfileService = UserProfileService(apiClient: self.mockAPIClient)
    }
}
