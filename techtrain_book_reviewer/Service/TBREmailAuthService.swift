//
//  TBREmailAuthService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/08.
//

import Foundation

actor TBREmailAuthService {
    private let apiClient: TechTrainAPIClientImpl
    
    init(apiClient: TechTrainAPIClientImpl) {
        self.apiClient = apiClient
    }
    
    func authenticateAndReturnToken(
        email: String,
        password: String,
        signUpName: String? = nil // `signUp` の場合は名前がある
        // token: Stringを返す
    ) async throws(TechTrainAPIError.ServiceError) -> String {
        let endpoint = signUpName == nil ? "/signin" : "/users" // `users` はサインアップ用エンドポイント
        var parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        // `signUp` の場合は名前を追加
        if let name = signUpName {
            parameters["name"] = name
        }
        
        do {
            let data = try await apiClient.makeRequestAsync(to: endpoint, method: "POST", body: parameters)
            // tokenを引き出す
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let token = json["token"] as? String else {
                throw TechTrainAPIError.decodingError
            }
            try await SecureTokenService.shared.saveAPIToken(data: Data(token.utf8))
            return token
        } catch {
            throw (error as? TechTrainAPIError)?.toServiceError() ?? TechTrainAPIError.ServiceError.underlyingError(.unknown)
        }
    }
}
