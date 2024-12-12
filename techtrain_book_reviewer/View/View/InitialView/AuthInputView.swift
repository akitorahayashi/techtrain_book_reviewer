//
//  AuthInputView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/12.
//

import UIKit

class AuthInputView: UIView {
    let emailTextField = TBRInputField(placeholder: "メールアドレス")
    let passwordTextField = TBRInputField(placeholder: "パスワード", isSecure: true)
    let nameTextField = TBRInputField(placeholder: "名前")
    
    let actionButton: TBRCardButton
    let clearButton: TBRCardButton
    
    init(authMode: AuthInputVC.EmailAuthMode, actionButtonAction: @escaping () -> Void, clearButtonAction: @escaping () -> Void) {
        let actionTitle = (authMode == .login) ? "ログイン" : "登録"
        self.actionButton = TBRCardButton(title: actionTitle, action: actionButtonAction)
        self.clearButton = TBRCardButton(title: "クリア", action: clearButtonAction)
        super.init(frame: .zero)
        setupUI(authMode: authMode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(authMode: AuthInputVC.EmailAuthMode) {
        backgroundColor = .systemBackground
        
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
    
    func clearInputFields() {
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
}
