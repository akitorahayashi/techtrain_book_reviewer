//
//  SignInViewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class SignInViewController: UIViewController {
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
        
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("サインイン", for: .normal)
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signUpButton, errorLabel])
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
    
    @objc private func handleSignUp() {
        guard let email = emailTextField.text, validateEmail(email),
              let password = passwordTextField.text, validatePassword(password) else {
            errorLabel.text = "入力エラー：メールアドレスまたはパスワードが不正です"
            return
        }
        
        // サインインAPI呼び出し（モック例）
        signUpUser(email: email, password: password) { [weak self] success in
            if success {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.errorLabel.text = "サインインエラー：登録に失敗しました"
            }
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        // 簡易バリデーション
        return email.contains("@")
    }
    
    private func validatePassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    private func signUpUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        // API呼び出しのモック処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true) // 成功時
        }
    }
}
