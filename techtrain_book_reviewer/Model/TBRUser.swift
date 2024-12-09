//
//  TBRUser.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/09.
//


struct TBRUser: Decodable {
    let token: String
    var name: String
    var iconUrl: String?
}
