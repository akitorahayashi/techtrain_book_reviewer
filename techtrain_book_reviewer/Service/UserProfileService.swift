//
//  TBRUserProfileService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/10.
//


import Foundation
import Combine

class UserProfileService {
    static var yourAccountPublisher = CurrentValueSubject<TBRUser?, Never>(nil)
    
    static var yourAccount: TBRUser? {
        get { yourAccountPublisher.value }
        set { yourAccountPublisher.send(newValue) }
    }
    
    private let apiClient: TechTrainAPIClient
    
    init(apiClient: TechTrainAPIClient = .shared) {
        self.apiClient = apiClient
    }
    
    enum UserProfileError: Error {
        case unauthorized       // 認証エラー
        case invalidRequest     // リクエストが不正
        case serverIssue        // サーバー側の問題
        case unknown            // その他不明なエラー
        case underlyingError(TechTrainAPIClient.APIError) // APIエラーをラップ
    }
    
    func updateUserName(
        withToken token: String,
        newName: String,
        completion: @escaping (Result<Void, TechTrainAPIClient.APIError>) -> Void
    ) {
        let endpoint = "/users"
        
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters = [
            "name": newName
        ]
        
        apiClient.makeRequest(to: endpoint, method: "PUT", parameters: parameters, headers: headers) { result in
            switch result {
            case .success:
                print("UserProfileService: ユーザー名の更新に成功しました")
                completion(.success(()))
            case .failure(let error):
                print("UserProfileService: ユーザー名の更新に失敗しました - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func fetchUserProfile(
        withToken token: String,
        completion: @escaping (Result<Void, TechTrainAPIClient.APIError>) -> Void
    ) {
        let endpoint = "/users"
        
        // ヘッダーの設定
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        // リクエストを送信
        apiClient.makeRequest(to: endpoint, method: "GET", parameters: nil, headers: headers) { result in
            switch result {
            case .success(let data):
                do {
                    // レスポンスをログ
                    print("レスポンスデータ: \(String(data: data, encoding: .utf8) ?? "データなし")")
                    
                    // JSONを解析してTBRUserを生成
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let name = json["name"] as? String,
                       let iconUrl = json["iconUrl"] as? String? {
                        let user = TBRUser(token: token, name: name, iconUrl: iconUrl)
                        
                        // 静的プロパティに格納
                        UserProfileService.yourAccount = user
                        
                        // 成功として通知
                        completion(.success(()))
                    } else {
                        print("JSON解析失敗: \(String(data: data, encoding: .utf8) ?? "データなし")")
                        completion(.failure(.decodingError))
                    }
                } catch let error as DecodingError {
                    print("デコードエラー: \(error)")
                    completion(.failure(.decodingError))
                } catch {
                    print("不明なエラー: \(error)")
                    completion(.failure(.unknown))
                }
                
            case .failure(let error):
                print("リクエスト失敗: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
