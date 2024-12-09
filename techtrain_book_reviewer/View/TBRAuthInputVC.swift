//
//  AuthInputView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class TBRAuthInputVC: UIViewController {
    enum EmailAuthMode {
        case login
        case signUp
    }
    
    private let authMode: EmailAuthMode
    private let emailTextField = TBRInputField(placeholder: "メールアドレス")
    private let passwordTextField = TBRInputField(placeholder: "パスワード", isSecure: true)
    private let nameTextField = TBRInputField(placeholder: "名前") // 名前入力フィールド
    private let authService: TBREmailAuthService
    
    private lazy var actionButton: TBRCardButton = {
        let title = (authMode == .login) ? "ログイン" : "登録"
        return TBRCardButton(title: title) { [weak self] in
            self?.authenticate()
        }
    }()
    
    private lazy var clearButton: TBRCardButton = {
        TBRCardButton(title: "クリア") { [weak self] in
            self?.clearInputFields()
        }
    }()
    
    init(authMode: EmailAuthMode, authService: TBREmailAuthService = TBREmailAuthService(apiClient: TechTrainAPIClient.shared)) {
        self.authMode = authMode
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // スタックビューの作成
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
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func clearInputFields() {
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func authenticate() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "入力エラー", message: "メールアドレスまたはパスワードを入力してください。")
            return
        }
        
        if authMode == .signUp {
            guard let name = nameTextField.text, !name.isEmpty else {
                showAlert(title: "入力エラー", message: "名前を入力してください。")
                return
            }
            
            showLoading()
            
            authService.authenticate(email: email, password: password, name: name, authMode: .signUp) { [weak self] result in
                DispatchQueue.main.async {
                    self?.hideLoading()
                    switch result {
                    case .success:
                        self?.showAlert(title: "成功", message: "登録しました！")
                    case .failure(let error):
                        self?.showAlert(title: "エラー", message: error.localizedDescription)
                    }
                }
            }
        } else {
            showLoading()
            
            authService.authenticate(email: email, password: password, authMode: .login) { [weak self] result in
                DispatchQueue.main.async {
                    self?.hideLoading()
                    switch result {
                    case .success:
                        self?.showAlert(title: "成功", message: "ログインしました！")
                    case .failure(let error):
                        self?.showAlert(title: "エラー", message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
