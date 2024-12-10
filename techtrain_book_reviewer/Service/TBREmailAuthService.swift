//
//  TBREmailAuthService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/08.
//

import Foundation

class TBREmailAuthService {
    private let apiClient: TechTrainAPIClient
    
    init(apiClient: TechTrainAPIClient) {
        self.apiClient = apiClient
    }
    
    enum AuthMode {
        case login
        case signUp
    }
    
    func authenticate(
        email: String,
        password: String,
        signUpName: String? = nil, // `signUp` の場合は名前がある
        authMode: AuthMode,
        completion: @escaping (Result<String, TechTrainAPIClient.APIError>) -> Void
    ) {
        let endpoint = authMode == .login ? "/signin" : "/users" // `users` はサインアップ用エンドポイント
        var parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        // `signUp` の場合は名前を追加
        if authMode == .signUp, let name = signUpName {
            parameters["name"] = name
        }
        
        apiClient.makeRequest(to: endpoint, method: "POST", parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    // レスポンスからトークンを取得
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String {
                        completion(.success(token))
                    } else {
                        completion(.failure(.decodingError))
                    }
                } catch {
                    completion(.failure(.decodingError))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
