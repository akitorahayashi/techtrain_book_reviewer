//
//  TBRCardButton.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class TBRCardButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setupUI(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String) {
        // ボタンの背景デザイン
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        // ボタンタイトルの設定
        setTitle(title, for: .normal)
        setTitleColor(.accent, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel?.textAlignment = .center
        
        // 高さ制約を固定
        heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    // タップ時の視覚効果
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isHighlighted ? 0.5 : 1.0
            }
        }
    }
}
