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
    
    func validateAndCleanName(_ name: String?) -> String? {
        guard let name = name?.replacingOccurrences(of: " ", with: ""), // すべての空白を削除
              !name.isEmpty, // 空白のみでないことを確認
              name.count <= 10 // 10文字以下であることを確認
        else {
            return nil // 無効な名前の場合はnilを返す
        }
        return name // 有効な名前を返す
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
