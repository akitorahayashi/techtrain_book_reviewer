//
//  BookReview.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

struct BookReview: Codable {
    let id: String
    let title: String
    let url: String?
    let detail: String
    let review: String
    let reviewer: String
    let isMine: Bool?
}
