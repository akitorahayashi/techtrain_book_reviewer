//
//  TBREmailAuthService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/08.
//

import Foundation

class UserProfileService {
    
    static var yourAccount: TBRUser? = nil
    
    private let apiClient: TechTrainAPIClient
    
    init(apiClient: TechTrainAPIClient = .shared) {
        self.apiClient = apiClient
    }
    
    
    /// ユーザー名を更新する
    func updateUserName(
        withToken token: String,
        newName: String,
        completion: @escaping (Result<Void, TechTrainAPIError.ServiceError>) -> Void
    ) {
        let endpoint = "/users"
        
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters = [
            "name": newName
        ]
        
        apiClient.makeRequest(to: endpoint, method: "PUT", body: parameters, headers: headers) { result in
            switch result {
            case .success:
                print("UserProfileService: ユーザー名の更新に成功しました")
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error.toServiceError()))
            }
        }
    }
    
    /// ユーザープロファイルを取得する
    func fetchUserProfile(
        withToken token: String,
        completion: @escaping (Result<Void, TechTrainAPIError.ServiceError>) -> Void
    ) {
        let endpoint = "/users"
        
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        apiClient.makeRequest(to: endpoint, method: "GET", body: nil, headers: headers) { result in
            switch result {
            case .success(let data):
                do {
                    print("レスポンスデータ: \(String(data: data, encoding: .utf8) ?? "データなし")")
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let name = json["name"] as? String,
                       let iconUrl = json["iconUrl"] as? String? {
                        let user = TBRUser(token: token, name: name, iconUrl: iconUrl)
                        UserProfileService.yourAccount = user
                        completion(.success(()))
                    } else {
                        print("JSON解析失敗")
                        completion(.failure(.underlyingError(.decodingError)))
                    }
                } catch {
                    print("JSON解析失敗")
                    completion(.failure(.underlyingError(.decodingError)))
                }
            case .failure(let error):
                completion(.failure(error.toServiceError()))
            }
        }
    }
}
