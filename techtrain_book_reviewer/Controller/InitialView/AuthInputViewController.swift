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
        super.loadView()
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
    
    // MARK: - 入力検証と認証処理
    private func validateInputs() -> (email: String, password: String, name: String?)? {
        guard let email = authInputView.emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = authInputView.passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !AuthInputValidationUtils.isBlank(email), !AuthInputValidationUtils.isBlank(password) else {
            showAlert(title: "入力エラー", message: "メールアドレスまたはパスワードを入力してください。")
            return nil
        }
        
        if !AuthInputValidationUtils.isValidEmail(email) {
            showAlert(title: "入力エラー", message: "正しい形式のメールアドレスを入力してください。")
            return nil
        }
        
        if !AuthInputValidationUtils.isValidPassword(password) {
            showAlert(title: "入力エラー", message: "パスワードは6文字以上20文字以下で設定してください。")
            return nil
        }
        
        if authMode == .signUp {
            guard let name = authInputView.nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  AuthInputValidationUtils.isValidName(name) else {
                showAlert(title: "入力エラー", message: "名前は10文字以下で空白以外の文字を含めてください。")
                return nil
            }
            return (email, password, name)
        }
        
        return (email, password, nil)
    }
    
    private func authenticate() {
        guard let validatedInputs = validateInputs() else { return }
        let email = validatedInputs.email
        let password = validatedInputs.password
        
        if authMode == .signUp {
            guard let name = validatedInputs.name else { return }
            
            confirmPassword(password: password) { [weak self] confirmed in
                guard let self = self, confirmed else {
                    self?.showAlert(title: "エラー", message: "再入力されたパスワードが一致しません。")
                    return
                }
                
                self.performSignUp(email: email, password: password, name: name)
            }
        } else {
            performLogin(email: email, password: password)
        }
    }
    
    // MARK: - パスワード再確認アラート
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
                    self?.showAlert(title: "エラー", message: error.localizedDescription)
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
                    self?.showAlert(title: "エラー", message: error.localizedDescription)
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
                    self?.showAlert(title: "エラー", message: error.localizedDescription)
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
    
    // MARK: - アラート表示
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
