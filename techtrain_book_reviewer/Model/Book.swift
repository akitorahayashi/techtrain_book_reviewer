//
//  Book.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

struct Book: Decodable {
    var id: String
    var title: String
    var url: String
    var detail: String
    var review: String
    var reviewer: String
}
