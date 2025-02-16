//
//  BookReviewService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import Foundation

actor BookReviewService {
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
        let body: [String: String] = [
            "title": title,
            "url": url,
            "detail": detail,
            "review": review
        ]
        do {
            let data = try await TechTrainAPIClientImpl.shared.makeRequestAsync(to: endpoint, method: "POST", headers: headers, body: body)
            return data
        } catch {
            throw error.toServiceError()
        }
    }
    
    // updateBookReview
    func updateAndReturnBookReview(
        id: String,
        title: String,
        url: String?,
        detail: String,
        review: String,
        token: String
    ) async throws(TechTrainAPIError.ServiceError) -> BookReview {
        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "/books/\(id)"
        let body: [String: String] = [
            "title": title,
            "url": url ?? "",
            "detail": detail,
            "review": review
        ]
        do {
            let postedBookReviewData = try await TechTrainAPIClientImpl.shared.makeRequestAsync(to: endpoint, method: "PUT", headers: headers, body: body)
            let postedBookReview = try BookReview.decodeSingleBookReview(postedBookReviewData)
            return postedBookReview
        } catch {
            throw error.toServiceError()
        }
    }
    
    // fetchBookReview・
    func fetchAndReturnBookReviewDetail(
        id: String,
        token: String
    ) async throws(TechTrainAPIError.ServiceError) -> BookReview {
        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "/books/\(id)"
        
        do {
            let bookReviewData = try await TechTrainAPIClientImpl.shared.makeRequestAsync(to: endpoint, method: "GET", headers: headers, body: nil)
            let decodedBookReview = try BookReview.decodeSingleBookReview(bookReviewData)
            return decodedBookReview
        } catch {
            throw error.toServiceError()
        }
    }
    
    // fetch reviews
    func fetchAndReturnBookReviews(
        offset: Int = 0,
        token: String
    ) async throws(TechTrainAPIError.ServiceError) -> [BookReview] {
        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "/books?offset=\(offset)"
        
        do {
            let data = try await TechTrainAPIClientImpl.shared.makeRequestAsync(to: endpoint, method: "GET", headers: headers, body: nil)
            let decodedBookReviews = try BookReview.decodeBookReviewList(data)
            return decodedBookReviews
        } catch {
            throw error.toServiceError()
        }
    }
    
    // Delete a review
    func deleteBookReview(
        id: String,
        token: String
    ) async throws(TechTrainAPIError.ServiceError) -> Void {
        let headers = ["Authorization": "Bearer \(token)"]
        let endpoint = "/books/\(id)"
        do {
            let _ = try await TechTrainAPIClientImpl.shared.makeRequestAsync(to: endpoint, method: "DELETE", headers: headers, body: nil)
        } catch {
            throw error.toServiceError()
        }
    }
}
