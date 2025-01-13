//
//  TBRNavigationBarTitle.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/13.
//

import UIKit

class TBRNavigationBarTitle: UILabel {
    init(title: String) {
        super.init(frame: .zero)
        setupUI(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(title: String) {
        text = title
        font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textAlignment = .center
        textColor = .accent
    }
}
