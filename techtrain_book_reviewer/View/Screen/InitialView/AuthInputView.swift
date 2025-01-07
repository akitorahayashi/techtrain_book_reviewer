//
//  AuthInputView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/12.
//

import UIKit

class AuthInputView: UIView {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    
    let emailTextField = TBRInputField("メールアドレス")
    let passwordTextField = TBRInputField("パスワード", isSecure: true)
    let nameTextField = TBRInputField("名前")
    
    let actionButton: TBRCardButton
    let clearButton: TBRCardButton
    
    init(authMode: AuthInputVC.EmailAuthMode) {
        let actionTitle = (authMode == .login) ? "ログイン" : "登録"
        self.actionButton = TBRCardButton(title: actionTitle)
        self.clearButton = TBRCardButton(title: "クリア")
        super.init(frame: .zero)
        setupUI(authMode: authMode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(authMode: AuthInputVC.EmailAuthMode) {
        backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // ボタンスタックビュー
        let buttonStackView = UIStackView(arrangedSubviews: [clearButton, actionButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        // `signUp` の場合のみ名前フィールドを追加
        let inputFields: [UIView] = (authMode == .signUp)
        ? [nameTextField, emailTextField, passwordTextField]
        : [emailTextField, passwordTextField]
        
        let stackView = UIStackView(arrangedSubviews: inputFields + [buttonStackView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}
