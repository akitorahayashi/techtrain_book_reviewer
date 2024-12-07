//
//  LogInViewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class LoginViewController: UIViewController {
    private let emailTextField = TBRInputField(placeholder: "email")
    private let passwordTextField = TBRInputField(placeholder: "パスワード", isSecure: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
    }
    
    private func setupUI() {
        // ログインボタン
        let loginButton = TBRCardButton(title: "ログイン", action: handleLogin)
        
        // クリアボタン
        let clearButton = TBRCardButton(title: "クリア", action: handleClear)
        
        // ボタンを並べるボタンバー
        let buttonBar = UIStackView(arrangedSubviews: [clearButton, loginButton])
        buttonBar.axis = .horizontal
        buttonBar.spacing = 20
        buttonBar.distribution = .fillEqually
        
        // メインのスタックビュー
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, UIView(), buttonBar])
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
    
    @objc private func handleClear() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func validateEmail(_ email: String) -> Bool {
        return email.contains("@")
    }
    
    private func validatePassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    private func authenticateUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
