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
        token: String
    ) async throws(TechTrainAPIError.ServiceError) -> Data {
        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "/books"
        let parameters: [String: Any] = [
            "title": title,
            "url": url,
            "detail": detail,
            "review": review
        ]
        do {
            let data = try await TechTrainAPIClient.shared.makeRequestAsync(to: endpoint, method: "POST", headers: headers, body: parameters)
            return data
        } catch {
            throw error.toServiceError()
        }
    }
    
    // updateBookReview
    func updateBookReview(
            id: String,
            title: String,
            url: String?,
            detail: String,
            review: String,
            token: String,
            completion: @escaping (Result<BookReview, TechTrainAPIError.ServiceError>) -> Void
        ) {
            let headers = ["Authorization": "Bearer \(token)"]
            let endpoint = "/books/\(id)"
            let parameters: [String: Any] = [
                "title": title,
                "url": url ?? "",
                "detail": detail,
                "review": review
            ]
            
            TechTrainAPIClient.shared.makeRequest(to: endpoint, method: "PUT", body: parameters, headers: headers) { result in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let updatedBookReview = try decoder.decode(BookReview.self, from: data)
                        completion(.success(updatedBookReview))
                    } catch {
                        completion(.failure(.underlyingError(.decodingError)))
                    }
                case .failure(let error):
                    completion(.failure(error.toServiceError()))
                }
            }
        }
    
    // fetchBookReview・
    func fetchBookReview(
            id: String,
            token: String,
            completion: @escaping (Result<BookReview, TechTrainAPIError.ServiceError>) -> Void
    ) async throws(TechTrainAPIError.ServiceError) -> BookReview {
            let headers = ["Authorization": "Bearer \(token)"]
            let endpoint = "/books/\(id)"
            
            do {
                let bookReviewData = try await TechTrainAPIClient.shared.makeRequestAsync(to: endpoint, method: "GET", headers: headers, body: nil)
                do {
                    let decoder = JSONDecoder()
                    let bookReview = try decoder.decode(BookReview.self, from: bookReviewData)
                    return bookReview
                } catch {
                    throw TechTrainAPIError.ServiceError.underlyingError(TechTrainAPIError.decodingError)
                }
            } catch {
                throw error.toServiceError()
            }
            
            { result in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let bookReview = try decoder.decode(BookReview.self, from: data)
                        completion(.success(bookReview))
                    } catch {
                        completion(.failure())
                    }
                case .failure(let error):
                    completion(.failure(error.toServiceError()))
                }
            }
        }
    
    // fetch reviews
    func fetchBookReviews(
        offset: Int = 0,
        token: String,
        completion: @escaping (Result<[BookReview], TechTrainAPIError.ServiceError>) -> Void
    ) {
        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "/books?offset=\(offset)"
        
        TechTrainAPIClient.shared.makeRequest(to: endpoint, method: "GET", body: nil, headers: headers) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let bookReviews = try decoder.decode([BookReview].self, from: data)
                    completion(.success(bookReviews))
                } catch {
                    print("fetchBookReviews デコードエラー: \(error)")
                    completion(.failure(.underlyingError(.decodingError)))
                }
            case .failure(let error):
                completion(.failure(error.toServiceError()))
            }
        }
    }
    
    // Delete a review
    func deleteBookReview(
        id: String,
        token: String,
        completion: @escaping (Result<Void, TechTrainAPIError.ServiceError>) -> Void
    ) {
        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "/books/\(id)"
        
        TechTrainAPIClient.shared.makeRequest(to: endpoint, method: "DELETE", body: nil, headers: headers) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error.toServiceError()))
            }
        }
    }
}
