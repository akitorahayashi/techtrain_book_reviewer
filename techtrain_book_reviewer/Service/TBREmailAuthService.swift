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
    
    func authenticate(
        email: String,
        password: String,
        signUpName: String? = nil, // `signUp` の場合は名前がある
        completion: @escaping (Result<String, TechTrainAPIClient.APIError>) -> Void
    ) {
        let endpoint = signUpName == nil ? "/signin" : "/users" // `users` はサインアップ用エンドポイント
        var parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        // `signUp` の場合は名前を追加
        if let name = signUpName {
            parameters["name"] = name
        }
        
        apiClient.makeRequest(to: endpoint, method: "POST", parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    // レスポンスからトークンを取得
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String {
                        // トークンを Keychain に保存
                        let tokenData = Data(token.utf8)
                        if SecureTokenService.shared.save(data: tokenData) {
                            completion(.success(token))
                        } else {
                            completion(.failure(.keychainSaveError("Keychainへのトークン保存に失敗しました。")))
                        }
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
