//
//  AuthInputView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class AuthInputVC: UIViewController {
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
            let userProfileService = UserProfileService()
            guard let cleanedName = userProfileService.validateAndCleanName(authInputView.nameTextField.text),
                  !cleanedName.isEmpty else {
                showSingleOptionAlert(
                    title: "入力エラー",
                    message: "名前は10文字以下で空白以外の文字を含めてください。"
                )
                return
            }

            showLoading()
            authService.authenticate(email: email, password: password, signUpName: cleanedName) { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleAuthResult(result.mapError { $0 as Error })
                }
            }
        } else {
            showLoading()
            authService.authenticate(email: email, password: password) { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleAuthResult(result.mapError { $0 as Error })
                }
            }
        }
    }

    private func handleAuthResult(_ result: Result<String, Error>) {
        switch result {
        case .success(let token):
            fetchUserProfileAndAlert(token: token)
        case .failure(let error):
            hideLoading()
            showSingleOptionAlert(title: "エラー", message: error.localizedDescription)
        }
    }
    
    private func fetchUserProfileAndAlert(token: String) {
        let userProfileService = UserProfileService()

        userProfileService.fetchUserProfile(withToken: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()

                switch result {
                case .success:
                    self?.showSuccessAlert()
                case .failure(let error):
                    self?.showSingleOptionAlert(title: "エラー", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "成功", message: "ログインしました！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigateToBookListVC()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func showSingleOptionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func navigateToBookListVC() {
        let mainTabBarController = MainTabBarController()
        let navigationController = UINavigationController(rootViewController: mainTabBarController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}
