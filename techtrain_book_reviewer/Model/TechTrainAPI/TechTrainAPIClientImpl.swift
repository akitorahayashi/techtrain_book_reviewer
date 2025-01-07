//
//  TechTrainAPIClient.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/09.
//

import Foundation

protocol TechTrainAPIClient {
    func makeRequestAsync(
        to endpoint: String,
        method: String,
        headers: [String: String]?,
        body: [String: Any]?
    ) async throws(TechTrainAPIError) -> Data
}

actor TechTrainAPIClientImpl {
    // インスタンス
    static let shared = TechTrainAPIClientImpl()
    // その他のメンバー
    private let baseURL = "https://railway.bookreview.techtrain.dev"
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    func makeRequestAsync(
        to endpoint: String,
        method: String,
        headers: [String: String]? = nil,
        body: [String: Any]?
    ) async throws(TechTrainAPIError) -> Data {
        guard let url = URL(string: baseURL + endpoint) else {
            print("URLが無効: \(baseURL + endpoint)")
            throw TechTrainAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let parameters = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print("パラメータのエンコードエラー: \(error)")
                throw TechTrainAPIError.encodingError
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TechTrainAPIError.invalidResponse
            }
            
            
            switch httpResponse.statusCode {
            case 200:
                return data
            default:
                // エラーの内容を解析してローカライズ
                let localizedError = self.parseServerError(from: data, statusCode: httpResponse.statusCode)
                throw localizedError
            }
        } catch {
            throw TechTrainAPIError.networkError
        }
    }
    
    private func parseServerError(from data: Data, statusCode: Int) -> TechTrainAPIError {
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
            // JSON解析中のエラー発生時に `.unknown` を返す
            return .unknown
        }
        
        // JSONが解析できない場合のエラー
        return .serverError(
            statusCode: statusCode,
            messageJP: "エラー内容の解析に失敗しました。JSON形式が無効です。",
            messageEN: "Failed to parse error details. The JSON format is invalid."
        )
    }

}
