//
//  AuthInputView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class TBRAuthInputVC: UIViewController {
    enum TBRInputAuthMode {
        case login
        case signUp
    }
    
    private let mode: TBRInputAuthMode
    private let emailTextField = TBRInputField(placeholder: "email")
    private let passwordTextField = TBRInputField(placeholder: "パスワード", isSecure: true)
    
    private lazy var actionButton: TBRCardButton = {
        switch mode {
        case .login:
            return TBRCardButton(title: "ログイン") { [weak self] in
                self?.handleLogin()
            }
        case .signUp:
            return TBRCardButton(title: "登録") { [weak self] in
                self?.handleSignUp()
            }
        }
    }()
    
    private lazy var clearButton: TBRCardButton = {
        TBRCardButton(title: "クリア") { [weak self] in
            self?.clearInputFields()
        }
    }()
    
    // カスタムイニシャライザ
    init(mode: TBRInputAuthMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    // coder イニシャライザは削除できないが、fatalError にしてサポートしない形にする
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        // ボタンを並べるスタックビュー
        let buttonStackView = UIStackView(arrangedSubviews: [clearButton, actionButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10
        buttonStackView.distribution = .fillEqually
        
        // メインのスタックビュー
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, buttonStackView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func clearInputFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func validateEmail(_ email: String) -> Bool {
        return email.contains("@")
    }
    
    private func validatePassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    private func authenticateUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
    }
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text, validateEmail(email),
              let password = passwordTextField.text, validatePassword(password) else {
            showAlert(title: "入力エラー", message: "メールアドレスまたはパスワードが不正です。")
            return
        }
        
        // ログインAPI呼び出し（モック例）
        authenticateUser(email: email, password: password) { [weak self] success in
            if success {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.showAlert(title: "ログインエラー", message: "認証に失敗しました。")
            }
        }
    }
    
    private func signUpUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        // API呼び出しのモック処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true) // 成功時
        }
    }
    
    @objc private func handleSignUp() {
        guard let email = emailTextField.text, validateEmail(email),
              let password = passwordTextField.text, validatePassword(password) else {
            showAlert(title: "入力エラー", message: "メールアドレスまたはパスワードが不正です。")
            return
        }
        
        // サインインAPI呼び出し（モック例）
        signUpUser(email: email, password: password) { [weak self] success in
            if success {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.showAlert(title: "入力エラー", message: "メールアドレスまたはパスワードが不正です。")
            }
        }
    }
}
