//
//  BookReview.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//
import Foundation

struct BookReview: Codable {
    let id: String
    let title: String
    let url: String
    let detail: String
    let review: String
    let reviewer: String
    let isMine: Bool?
    
    /// 単一のBookReviewに対するデコード
    static func decodeSingleBookReview(_ data: Data) throws(TechTrainAPIError) -> BookReview {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(BookReview.self, from: data)
        } catch {
            throw TechTrainAPIError.decodingError
        }
    }
    
    /// 配列形式に対する`BookReview`のデコード
    static func decodeBookReviewList(_ data: Data) throws(TechTrainAPIError) -> [BookReview] {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([BookReview].self, from: data)
        } catch {
            throw TechTrainAPIError.decodingError
        }
    }
}
