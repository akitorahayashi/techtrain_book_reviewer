//
//  HomeView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/10.
//

import UIKit

class HomeView: UIView {
    let yourAccount: TBRUser
    let bookReviewListView = BookReviewListView()
    
    init(yourAccount: TBRUser) {
        self.yourAccount = yourAccount
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        
        // BookReviewListView を追加
        addSubview(bookReviewListView)
        
        // レイアウト設定
        NSLayoutConstraint.activate([
            
            bookReviewListView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            bookReviewListView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bookReviewListView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bookReviewListView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
