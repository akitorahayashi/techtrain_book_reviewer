//
//  MockTechTrainAPIClient.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/08.
//

import Foundation
@testable import techtrain_book_reviewer

actor MockTechTrainAPIClient: TechTrainAPIClient {
    var responseData: Data?
    var shouldThrowError = false
    
    func setResponseData(_ data: Data?) async {
        self.responseData = data
    }
    
    func setShouldThrowError(_ shouldThrow: Bool) async {
        self.shouldThrowError = shouldThrow
    }
    
    
    func makeRequestAsync(to endpoint: String, method: String, headers: [String : String]? = nil, body: [String : String]?) async throws(techtrain_book_reviewer.TechTrainAPIError) -> Data {
        if shouldThrowError {
            throw TechTrainAPIError.networkError
        }
        
        guard let response = responseData else {
            throw TechTrainAPIError.invalidResponse
        }
        
        return response
    }
}
