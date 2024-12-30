//
//  AuthInputView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class AuthInputViewController: UIViewController {
    // MARK: - Enums
    enum EmailAuthMode {
        case login
        case signUp
    }
    
    // MARK: - Properties
    private let authMode: EmailAuthMode
    private let authService: TBREmailAuthService
    private var authInputView: AuthInputView!
    
    // MARK: - Initializers
    init(authMode: EmailAuthMode, authService: TBREmailAuthService = TBREmailAuthService(apiClient: TechTrainAPIClient.shared)) {
        self.authMode = authMode
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        authInputView = AuthInputView(
            authMode: authMode,
            actionButtonAction: { [weak self] in self?.authenticate() },
            clearButtonAction: { [weak self] in self?.authInputView.clearInputFields() }
        )
        view = authInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismissTapGesture()
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
            TBRAlertHelper.showSingleOptionAlert(on: self, title: "入力エラー", message: firstErrorMessage)
            return nil
        }
        
        // バリデーションを通過した場合、入力値を返す
        return (email, password, name)
    }
    // MARK: - 認証処理
    private func authenticate() {
        guard let validatedInputs = validateAndShowErrors() else { return }
        let email = validatedInputs.email
        let password = validatedInputs.password
        
        if authMode == .signUp {
            guard let name = validatedInputs.name else { return }
            
            confirmPassword(password: password) { [weak self] confirmed in
                guard let self = self, confirmed else {
                    TBRAlertHelper.showSingleOptionAlert(on: self, title: "エラー", message: "再入力されたパスワードが一致しません")
                    return
                }
                
                self.performSignUp(email: email, password: password, name: name)
            }
        } else {
            performLogin(email: email, password: password)
        }
    }
    // MARK: - パスワードを2回目に入力させるためのアラート
    private func confirmPassword(password: String, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "パスワード再確認", message: "もう一度パスワードを入力してください。", preferredStyle: .alert)
        alert.addTextField { $0.isSecureTextEntry = true }
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { _ in
            let confirmedPassword = alert.textFields?.first?.text
            completion(confirmedPassword == password)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            completion(false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - ログイン処理
    private func performLogin(email: String, password: String) {
        LoadingOverlayService.shared.show()
        authService.authenticate(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                LoadingOverlayService.shared.hide()
                switch result {
                case .success(let token):
                    self?.fetchUserProfile(token: token, isSignUp: false)
                case .failure(let error):
                    TBRAlertHelper.showSingleOptionAlert(on: self, title: "エラー", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - サインアップ処理
    private func performSignUp(email: String, password: String, name: String) {
        LoadingOverlayService.shared.show()
        authService.authenticate(email: email, password: password, signUpName: name) { [weak self] result in
            DispatchQueue.main.async {
                LoadingOverlayService.shared.hide()
                switch result {
                case .success(let token):
                    self?.fetchUserProfile(token: token, isSignUp: true)
                case .failure(let error):
                    TBRAlertHelper.showSingleOptionAlert(on: self, title: "エラー", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - プロファイル取得
    private func fetchUserProfile(token: String, isSignUp: Bool) {
        LoadingOverlayService.shared.show()
        let userProfileService = UserProfileService()
        userProfileService.fetchUserProfile(withToken: token) { [weak self] result in
            DispatchQueue.main.async {
                LoadingOverlayService.shared.hide()
                switch result {
                case .success:
                    let message = isSignUp ? "登録が完了しました！" : "ログインしました！"
                    let alert = UIAlertController(title: "成功", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                        self?.navigateToMain()
                    }))
                    self?.present(alert, animated: true, completion: nil)
                case .failure(let error):
                    TBRAlertHelper.showSingleOptionAlert(on: self, title: "エラー", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - ナビゲーション
    private func navigateToMain() {
        let mainTabBarController = MainTabBarController()
        mainTabBarController.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(mainTabBarController, animated: true)
    }
}
