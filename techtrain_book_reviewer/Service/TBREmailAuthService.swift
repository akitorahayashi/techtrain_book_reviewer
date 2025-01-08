//
//  TBREmailAuthService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/08.
//

import Foundation

actor TBREmailAuthService {
    nonisolated private let apiClient: TechTrainAPIClient
    
    init(apiClient: TechTrainAPIClient = TechTrainAPIClientImpl.shared) {
        self.apiClient = apiClient
    }
    
    func authenticateAndReturnToken(
        email: String,
        password: String,
        signUpName: String? = nil // `signUp` の場合は名前がある
    ) async throws -> String {
        let endpoint = signUpName == nil ? "/signin" : "/users" // `users` はサインアップ用エンドポイント
        var body: [String: String] = [
            "email": email,
            "password": password
        ]
        
        // `signUp` の場合は名前を追加
        if let name = signUpName {
            body["name"] = name
        }
        
        do {
            // アクター内で非同期タスクを安全に呼び出す
            let data = try await self.apiClient.makeRequestAsync(to: endpoint, method: "POST", headers: nil, body: body)
            
            // tokenを引き出す
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let token = json["token"] as? String else {
                throw TechTrainAPIError.decodingError
            }
            
            // APIトークンをセキュアに保存
            try await SecureTokenService.shared.saveAPIToken(data: Data(token.utf8))
            return token
        } catch {
            // エラーハンドリング
            throw (error as? TechTrainAPIError)?.toServiceError() ?? TechTrainAPIError.ServiceError.underlyingError(.unknown)
        }
    }
}
