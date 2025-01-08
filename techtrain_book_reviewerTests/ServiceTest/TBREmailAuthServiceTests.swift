//
//  TBREmailAuthServiceTests.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/09.
//

import XCTest
@testable import techtrain_book_reviewer

class TBREmailAuthServiceTests: XCTestCase {
    private var mockAPIClient: MockTechTrainAPIClient!
    private var mockTBREmailAuthService: TBREmailAuthService!
    
    override func setUp() {
        super.setUp()
        self.mockAPIClient = MockTechTrainAPIClient()
        self.mockTBREmailAuthService = TBREmailAuthService(apiClient: self.mockAPIClient)
    }
    
    override func tearDown() {
        self.mockAPIClient = nil
        self.mockTBREmailAuthService = nil
        super.tearDown()
    }
    
    func testAuthenticateSuccess() async throws {
        // Arrange
        let email = "test@example.com"
        let password = "password123"
        let testToken = "test-token"
        let mockResponseData: [String: Any] = ["token": testToken]
        await mockAPIClient.setResponseData(try JSONSerialization.data(withJSONObject: mockResponseData, options: []))
        
        // Act
        let returnedToken = try await mockTBREmailAuthService.authenticateAndReturnToken(email: email, password: password)
        
        // Assert
        XCTAssertEqual(returnedToken, testToken)
    }
    
    func testAuthenticateFailure() async {
        // Arrange
        let email = "test@example.com"
        let password = "password123"
        await mockAPIClient.setShouldThrowError(true)
        
        // Act & Assert
        do {
            _ = try await mockTBREmailAuthService.authenticateAndReturnToken(email: email, password: password)
            XCTFail("Expected an error to be thrown")
        } catch {
            // Success
        }
    }
    
    func testSignUpSuccess() async throws {
        // Arrange
        let email = "test@example.com"
        let password = "password123"
        let signUpName = "Test User"
        let testToken = "test-token"
        let mockResponseData: [String: Any] = ["token": testToken]
        await mockAPIClient.setResponseData(try JSONSerialization.data(withJSONObject: mockResponseData, options: []))
        
        // Act
        let returnedToken = try await mockTBREmailAuthService.authenticateAndReturnToken(email: email, password: password, signUpName: signUpName)
        
        // Assert
        XCTAssertEqual(returnedToken, testToken)
    }
    
    func testSignUpFailure() async {
        // Arrange
        let email = "test@example.com"
        let password = "password123"
        let signUpName = "Test User"
        await mockAPIClient.setShouldThrowError(true)
        
        // Act & Assert
        do {
            _ = try await mockTBREmailAuthService.authenticateAndReturnToken(email: email, password: password, signUpName: signUpName)
            XCTFail("Expected an error to be thrown")
        } catch {
            // Success
        }
    }
}
