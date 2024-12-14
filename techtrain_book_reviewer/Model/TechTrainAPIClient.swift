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
        headers: [String: String]? = nil,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            print("URLが無効: \(baseURL + endpoint)")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print("パラメータのエンコードエラー: \(error)")
                completion(.failure(.networkError(error)))
                return
            }
        }
        
        print("リクエスト送信: \(url)")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("リクエストエラー: \(error)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("HTTPレスポンスが無効")
                completion(.failure(.unknown))
                return
            }
            
            print("HTTPステータスコード: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("レスポンスデータが空")
                completion(.failure(.unknown))
                return
            }
            
            print("レスポンスデータ取得成功")
            
            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(data))
            default:
                // エラーの内容を解析してローカライズ
                let localizedError = self.parseServerError(from: data, statusCode: httpResponse.statusCode)
                completion(.failure(localizedError))
            }
        }
        
        task.resume()
    }
    
    private func parseServerError(from data: Data, statusCode: Int) -> APIError {
        do {
            // サーバーエラーのJSONレスポンスを解析
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let messageJP = json["ErrorMessageJP"] as? String,
               let messageEN = json["ErrorMessageEN"] as? String {
                return .serverError(
                    statusCode: statusCode,
                    messageJP: messageJP,
                    messageEN: messageEN
                )
            }
        } catch {
            print("エラーJSONレスポンスの解析失敗: \(error)")
        }
        
        // JSONが解析できない場合のエラー
        return .serverError(
            statusCode: statusCode,
            messageJP: "エラー内容の解析に失敗しました。JSON形式が無効です。",
            messageEN: "Failed to parse error details. The JSON format is invalid."
        )
    }
    
    
    
    
}
