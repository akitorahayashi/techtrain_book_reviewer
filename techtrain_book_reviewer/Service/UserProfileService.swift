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
    
    
    /// ユーザー名を更新する
    func updateUserName(
        withToken token: String,
        newName: String,
        completion: @escaping (Result<Void, UserProfileError>) -> Void
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
            case .failure(let apiError):
                let userProfileError = self.mapToUserProfileError(from: apiError)
                print("UserProfileService: ユーザー名の更新に失敗しました - \(userProfileError)")
                completion(.failure(userProfileError))
            }
        }
    }
    
    /// ユーザープロファイルを取得する
    func fetchUserProfile(
        withToken token: String,
        completion: @escaping (Result<Void, UserProfileError>) -> Void
    ) {
        let endpoint = "/users"
        
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        apiClient.makeRequest(to: endpoint, method: "GET", parameters: nil, headers: headers) { result in
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
                        completion(.failure(.unknown))
                    }
                } catch {
                    print("JSONデコードエラー: \(error)")
                    completion(.failure(.unknown))
                }
            case .failure(let apiError):
                let userProfileError = self.mapToUserProfileError(from: apiError)
                print("UserProfileService: ユーザープロファイルの取得に失敗しました - \(userProfileError)")
                completion(.failure(userProfileError))
            }
        }
    }
    
    enum UserProfileError: Error {
        case unauthorized       // 認証エラー
        case invalidRequest     // リクエストが不正
        case serverIssue        // サーバー側の問題
        case conflict           // 競合エラー（例: 重複データ）
        case serviceUnavailable // サービスが利用不可
        case notFound           // リソースが見つからない
        case unknown            // その他不明なエラー
        case underlyingError(TechTrainAPIClient.APIError) // APIエラーをラップ
    }
    
    private func mapToUserProfileError(from apiError: TechTrainAPIClient.APIError) -> UserProfileError {
        switch apiError {
        case .serverError(let statusCode, let messageJP, _):
            switch statusCode {
            case 400:
                print("UserProfileService: バリデーションエラー - \(messageJP)")
                return .invalidRequest
            case 401:
                print("UserProfileService: 認証エラー - \(messageJP)")
                return .unauthorized
            case 404:
                print("UserProfileService: リソースが見つかりません - \(messageJP)")
                return .notFound
            case 409:
                print("UserProfileService: 競合エラー - \(messageJP)")
                return .conflict
            case 503:
                print("UserProfileService: サービス利用不可 - \(messageJP)")
                return .serviceUnavailable
            default:
                print("UserProfileService: サーバー側の問題 - \(messageJP)")
                return .serverIssue
            }
        default:
            return .underlyingError(apiError)
        }
    }
}
