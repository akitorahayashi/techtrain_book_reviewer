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
    private let authService: TBREmailAuthService
    private var authInputView: TBRAuthInputView!
    
    init(authMode: EmailAuthMode, authService: TBREmailAuthService = TBREmailAuthService(apiClient: TechTrainAPIClient.shared)) {
        self.authMode = authMode
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        authInputView = TBRAuthInputView(
            authMode: authMode,
            actionButtonAction: { [weak self] in self?.authenticate() },
            clearButtonAction: { [weak self] in self?.authInputView.clearInputFields() }
        )
        view = authInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func authenticate() {
        guard let email = authInputView.emailTextField.text, !email.isEmpty,
              let password = authInputView.passwordTextField.text, !password.isEmpty else {
            showSingleOptionAlert(title: "入力エラー", message: "メールアドレスまたはパスワードを入力してください。")
            return
        }

        if authMode == .signUp {
            guard let name = authInputView.nameTextField.text, !name.isEmpty else {
                showSingleOptionAlert(title: "入力エラー", message: "名前を入力してください。")
                return
            }

            showLoading()
            authService.authenticate(email: email, password: password, name: name, authMode: .signUp) { [weak self] result in
                let mappedResult = result.mapError { $0 as Error }
                DispatchQueue.main.async {
                    self?.handleAuthResult(mappedResult)
                }
            }
        } else {
            showLoading()
            authService.authenticate(email: email, password: password, authMode: .login) { [weak self] result in
                let mappedResult = result.mapError { $0 as Error }
                DispatchQueue.main.async {
                    self?.handleAuthResult(mappedResult)
                }
            }
        }
    }

    
    private func handleAuthResult(_ result: Result<String, Error>) {
        hideLoading()
        switch result {
        case .success(let token):
            fetchUserProfileAndAlert(token: token)
        case .failure(let error):
            showSingleOptionAlert(title: "エラー", message: error.localizedDescription)
        }
    }
    
    private func fetchUserProfileAndAlert(token: String) {
        let userProfileManager = TBRUserProfileManager()
        userProfileManager.fetchUserProfile(withToken: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tbrUser):
                    let alert = UIAlertController(title: "成功", message: "ログインしました！", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                        self?.navigateToHomeVC(tbrUser: tbrUser)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                case .failure(let error):
                    self?.showSingleOptionAlert(title: "エラー", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showSingleOptionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func navigateToHomeVC(tbrUser: TBRUser) {
        let homeVC = HomeViewController(tbrUser: tbrUser)
        navigationController?.pushViewController(homeVC, animated: true)
    }
}
