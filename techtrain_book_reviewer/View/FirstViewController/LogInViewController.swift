//
//  LogInViewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class LoginViewController: UIViewController {
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI() {
        emailTextField.placeholder = "メールアドレス"
        emailTextField.borderStyle = .roundedRect
        
        passwordTextField.placeholder = "パスワード"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("ログイン", for: .normal)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, errorLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text, validateEmail(email),
              let password = passwordTextField.text, validatePassword(password) else {
            errorLabel.text = "入力エラー：メールアドレスまたはパスワードが不正です"
            return
        }
        
        // ログインAPI呼び出し（モック例）
        authenticateUser(email: email, password: password) { [weak self] success in
            if success {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.errorLabel.text = "ログインエラー：認証に失敗しました"
            }
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        return email.contains("@")
    }
    
    private func validatePassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    private func authenticateUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true) // 成功時
        }
    }
}
