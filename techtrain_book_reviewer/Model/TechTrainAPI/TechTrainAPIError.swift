//
//  TechTrainAPIError.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/14.
//

enum TechTrainAPIError: Error {
    case invalidURL
    case networkError
    case serverError(statusCode: Int, messageJP: String, messageEN: String)
    // Jsonシリアライズ
    case encodingError
    case decodingError
    // レスポンスの解析
    case invalidResponse
    case responseIsEmpty
    // keychain
    case keychainSaveError
    // エラー解析
    case failedToAnalyzeError
    // 不明
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "無効なURLです。"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .serverError(let statusCode, let messageJP, let messageEN):
            return "サーバーエラーが発生しました (\(statusCode)):\nJP: \(messageJP)\nEN: \(messageEN)"
        // Jsonシリアライズ
        case .encodingError:
            return "データの変換に失敗しました。"
        case .decodingError:
            return "データの解読に失敗しました。"
        // レスポンスの解析
        case .invalidResponse:
            return "HTTPレスポンスが無効です。"
        case .responseIsEmpty:
            return "レスポンスデータが空です。"
        // keychain
        case .keychainSaveError:
            return "端末内への保存中にエラーが発生しました。"
        // エラー解析
        case .failedToAnalyzeError:
            return "Network層のエラー解析に失敗しました。"
        // 不明
        case .unknown:
            return "不明なエラーが発生しました。"
        }
    }
    
    // サービス層でエラーを細分化
    func toServiceError() -> ServiceError {
        switch self {
        case .serverError(let statusCode, let messageJP, let messageEN):
            switch statusCode {
            case 400:
                print("Service: バリデーションエラー - \(messageJP)")
                return .invalidRequest(messageJP: messageJP, messageEN: messageEN)
            case 401:
                print("Service: 認証エラー - \(messageJP)")
                return .unauthorized(messageJP: messageJP, messageEN: messageEN)
            case 404:
                print("Service: リソースが見つかりません - \(messageJP)")
                return .notFound(messageJP: messageJP, messageEN: messageEN)
            case 409:
                print("Service: 競合エラー - \(messageJP)")
                return .conflict(messageJP: messageJP, messageEN: messageEN)
            case 503:
                print("Service: サービス利用不可 - \(messageJP)")
                return .serviceUnavailable(messageJP: messageJP, messageEN: messageEN)
            default:
                print("Service: サーバー側の問題 - \(messageJP)")
                return .serverIssue(messageJP: messageJP, messageEN: messageEN)
            }
        default:
            return .underlyingError(self)
        }
    }
    
    /// サービス独自のエラー型
    enum ServiceError: Error {
        case invalidRequest(messageJP: String, messageEN: String)
        case unauthorized(messageJP: String, messageEN: String)
        case notFound(messageJP: String, messageEN: String)
        case conflict(messageJP: String, messageEN: String)
        case serviceUnavailable(messageJP: String, messageEN: String)
        case serverIssue(messageJP: String, messageEN: String)
        case underlyingError(TechTrainAPIError)
        case unknown
        
        var localizedDescription: String {
            switch self {
            case .invalidRequest(let messageJP, _):
                return messageJP
            case .unauthorized(let messageJP, _):
                return messageJP
            case .notFound(let messageJP, _):
                return messageJP
            case .conflict(let messageJP, _):
                return messageJP
            case .serviceUnavailable(let messageJP, _):
                return messageJP
            case .serverIssue(let messageJP, _):
                return messageJP
            case .underlyingError(let error):
                return error.localizedDescription
            case .unknown:
                return "不明なエラーが発生しました。"
            }
        }
    }
}
