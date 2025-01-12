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
    
    
    let emailTextField = TBRInputField(placeholder: "メールアドレス")
    let passwordTextField = TBRInputField(placeholder: "パスワード", isSecure: true)
    let nameTextField = TBRInputField(placeholder: "名前")
    
    let actionButton: TBRCardButton
    let clearButton: TBRCardButton
    
    init(authMode: EmailAuthMode) {
        self.actionButton = TBRCardButton()
        self.clearButton = TBRCardButton()
        super.init(frame: .zero)
        setupUI(authMode: authMode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(authMode: EmailAuthMode) {
        backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // ボタンスタックビュー
        actionButton.setTitle((authMode == .login) ? "ログイン" : "登録", for: .normal)
        clearButton.setTitle("クリア", for: .normal)
        let buttonStackView = UIStackView(arrangedSubviews: [clearButton, actionButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        
        // `signUp` の場合のみ名前フィールドを追加
        let inputFields: [UIView] = (authMode == .signUp)
        ? [nameTextField, emailTextField, passwordTextField]
        : [emailTextField, passwordTextField]
        
        let formStackView = UIStackView(arrangedSubviews: inputFields + [buttonStackView])
        formStackView.axis = .vertical
        formStackView.spacing = 20
        formStackView.alignment = .fill
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(formStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            formStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            formStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            formStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            formStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}
