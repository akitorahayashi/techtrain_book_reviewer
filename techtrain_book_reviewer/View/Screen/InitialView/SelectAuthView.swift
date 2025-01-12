//
//  SelectAuthView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/12.
//

import UIKit

class SelectAuthView: UIView {
    private let appNameLabel = UILabel()
    
    let showSignUpPageButton = TBRCardButton()
    let showLogInPageButton = TBRCardButton()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // タイトルラベルを追加
        appNameLabel.text = "Book Reviewer"
        appNameLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        appNameLabel.textAlignment = .center
        appNameLabel.textColor = .accent
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appNameLabel)
        NSLayoutConstraint.activate([
            appNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            appNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50)
        ])
        
        // ボタンのスタックビューを作成
        showSignUpPageButton.setTitle("Sign up", for: .normal)
        showLogInPageButton.setTitle("Log in", for: .normal)
        let buttonStack = UIStackView(arrangedSubviews: [showSignUpPageButton, showLogInPageButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.alignment = .fill
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
