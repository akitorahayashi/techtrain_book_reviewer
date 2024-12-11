//
//  BookReviewService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import Foundation

class BookReviewService {
    static let shared = BookReviewService()
    
    private init() {}
    
    // Post a review
    func postBookReview(
        title: String,
        url: String,
        detail: String,
        review: String,
        token: String,
        completion: @escaping (Result<Void, TechTrainAPIClient.APIError>) -> Void
    ) {
        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "/books"
        let parameters: [String: Any] = [
            "title": title,
            "url": url,
            "detail": detail,
            "review": review
        ]
        
        TechTrainAPIClient.shared.makeRequest(to: endpoint, method: "POST", parameters: parameters, headers: headers) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // fetch reviews
    func fetchBookReviews(
        offset: Int = 0,
        token: String,
        completion: @escaping (Result<[BookReview], TechTrainAPIClient.APIError>) -> Void
    ) {
        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "/books?offset=\(offset)"
        
        TechTrainAPIClient.shared.makeRequest(to: endpoint, method: "GET", parameters: nil, headers: headers) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let bookReviews = try decoder.decode([BookReview].self, from: data)
                    completion(.success(bookReviews))
                } catch {
                    print("fetchBookReviews デコードエラー: \(error)")
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
