//
//  AuthInputView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

enum EmailAuthMode {
    case login
    case signUp
}

class AuthInputVC: UIViewController {
    private let authMode: EmailAuthMode
    private var authInputView: AuthInputView
    private weak var authInputCoordinator: AuthInputCoordinator?
    
    
    // MARK: - Initializers
    init(authMode: EmailAuthMode, authInputCoordinator: AuthInputCoordinator?) {
        self.authMode = authMode
        self.authInputView = AuthInputView(authMode: self.authMode)
        self.authInputCoordinator = authInputCoordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        super.loadView()
        view = self.authInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authInputView.actionButton.addTarget(self, action: #selector(authButtonAction), for: .touchUpInside)
        authInputView.clearButton.addTarget(self, action: #selector(clearInputFields), for: .touchUpInside)
        setupKeyboardDismissTapGesture()
    }
    
    // MARK: - 入力フォームをクリアする処理
    @objc func clearInputFields() {
        self.authInputView.nameTextField.text = ""
        self.authInputView.emailTextField.text = ""
        self.authInputView.passwordTextField.text = ""
    }
    
    // MARK: - 入力検証とエラー表示
    /// 入力値を検証し、エラーがあればアラートを表示。すべてクリアした場合、入力値をタプルで返す。
    private func validateAndShowErrors() -> (email: String, password: String, name: String?)? {
        guard let email = authInputView.emailTextField.text,
              let password = authInputView.passwordTextField.text else {
            return nil
        }
        
        let name = authInputView.nameTextField.text
        let validationErrorMessages = TBRAuthInputValidator.validateAuthInput(email: email, password: password, name: name, mode: authMode)
        
        // エラーがある場合、最初のエラーをアラートで表示
        if let firstErrorMessage = validationErrorMessages.first {
            TBRAlertHelper.showErrorAlert(on: self, message: firstErrorMessage)
            return nil
        }
        
        // バリデーションを通過した場合、入力値を返す
        return (email, password, name)
    }
    // MARK: - 認証処理
    @objc private func authButtonAction() {
        guard let validatedInputs = validateAndShowErrors() else { return }
        let email = validatedInputs.email
        let password = validatedInputs.password
        
        Task {
            if authMode == .signUp {
                guard let name = validatedInputs.name else { return }
                await confirmPasswordAsync(password: password) { [weak self] confirmed in
                    guard let self = self, confirmed else {
                        TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "エラー", message: "再入力されたパスワードが一致しません")
                        return
                    }
                    Task {
                        await self.performSignUp(email: email, password: password, name: name)
                    }
                }
            } else {
                await performLoginAsync(email: email, password: password)
            }
        }
    }
    // MARK: - パスワードを2回目に入力させるためのアラート
    private func confirmPasswordAsync(password: String, completion: @escaping (Bool) -> Void) async {
        let alert = UIAlertController(title: "パスワード再確認", message: "もう一度パスワードを入力してください。", preferredStyle: .alert)
        alert.addTextField { $0.isSecureTextEntry = true }
        alert.addAction(UIAlertAction(title: "確認", style: .default) { _ in
            let confirmedPassword = alert.textFields?.first?.text
            completion(confirmedPassword == password)
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            completion(false)
        })
        await MainActor.run {
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - サインアップ処理
    private func performSignUp(email: String, password: String, name: String) async {
        LoadingOverlay.shared.show()
        let authService = TBREmailAuthService(apiClient: TechTrainAPIClientImpl.shared)
        do {
            let token = try await authService.authenticateAndReturnToken(email: email, password: password, signUpName: name)
            await self.fetchAndSetupUserProfile(token: token, isSignUp: true)
        } catch let serviceError {
            TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
        }
    }
    
    // MARK: - ログイン処理
    private func performLoginAsync(email: String, password: String) async {
        LoadingOverlay.shared.show()
        let authService = TBREmailAuthService(apiClient: TechTrainAPIClientImpl.shared)
        do {
            let token = try await authService.authenticateAndReturnToken(email: email, password: password)
            await self.fetchAndSetupUserProfile(token: token, isSignUp: false)
        } catch let serviceError {
            TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
        }
        LoadingOverlay.shared.hide()
    }
    
    // MARK: - プロファイル取得
    private func fetchAndSetupUserProfile(token: String, isSignUp: Bool) async {
        LoadingOverlay.shared.show()
        do {
            try await UserProfileService().fetchUserProfileAndSetSelfAccount(withToken: token)
            let message = isSignUp ? "登録が完了しました！" : "ログインしました！"
            TBRAlertHelper.showSingleOKOptionAlert(on: self, title: "成功", message: message) { [weak self] _ in
                Task {
                    await self?.authInputCoordinator?.navigateToMainTabBarView()
                }
            }
        } catch let serviceError {
            TBRAlertHelper.showErrorAlert(on: self, message: serviceError.localizedDescription)
        }
        LoadingOverlay.shared.hide()
    }
}
