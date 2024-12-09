//
//  TechTrainAPIClient.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/09.
//

import Foundation

class TechTrainAPIClient {
    // インスタンス
    static let shared = TechTrainAPIClient()
    // その他のメンバー
    private let baseURL = "https://railway.bookreview.techtrain.dev"
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    func makeRequest(
        to endpoint: String,
        method: String,
        parameters: [String: Any]?,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                completion(.failure(.networkError(error)))
                return
            }
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(data))
                
            default:
                do {
                    let errorResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let errorCode = errorResponse?["ErrorCode"] as? Int ?? httpResponse.statusCode
                    let messageJP = errorResponse?["ErrorMessageJP"] as? String ?? "不明なエラー"
                    let messageEN = errorResponse?["ErrorMessageEN"] as? String ?? "Unknown error"
                    completion(.failure(.serverError(statusCode: errorCode, messageJP: messageJP, messageEN: messageEN)))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    enum APIError: Error {
        case invalidURL
        case networkError(Error)
        case serverError(statusCode: Int, messageJP: String, messageEN: String)
        case decodingError
        case unknown
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "無効なURLです。"
            case .networkError(let error):
                return "ネットワークエラーが発生しました: \(error.localizedDescription)"
            case .serverError(let statusCode, let messageJP, let messageEN):
                return "サーバーエラーが発生しました (\(statusCode)):\nJP: \(messageJP)\nEN: \(messageEN)"
            case .decodingError:
                return "データの解読に失敗しました。"
            case .unknown:
                return "不明なエラーが発生しました。"
            }
        }
    }
}
