//
//  AuthInputView.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class AuthInputVC: UIViewController {
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
    
    // MARK: - Authenticate
    private func authenticate() {
        // MARK: - 入力データ取得
        guard let email = authInputView.emailTextField.text?.replacingOccurrences(of: " ", with: ""),
              let password = authInputView.passwordTextField.text?.replacingOccurrences(of: " ", with: ""),
              !email.isEmpty, !password.isEmpty else {
            showAlert(title: "入力エラー", message: "メールアドレスまたはパスワードを入力してください。")
            return
        }

        // MARK: - バリデーション
        if authMode == .signUp {
            // メールアドレスの形式チェック
            if !isValidEmail(email) {
                showAlert(title: "入力エラー", message: "正しい形式のメールアドレスを入力してください。")
                return
            }
            
            // パスワードの長さチェック
            if password.count < 6 {
                showAlert(title: "入力エラー", message: "パスワードは6文字以上で設定してください。")
                return
            }

            // 名前のバリデーション
            guard let name = authInputView.nameTextField.text?.replacingOccurrences(of: " ", with: ""),
                  !name.isEmpty, name.count <= 10 else {
                showAlert(title: "入力エラー", message: "名前は10文字以下で空白以外の文字を含めてください。")
                return
            }

            // パスワード再確認アラート
            confirmPassword(password: password) { [weak self] confirmed in
                guard let self = self, confirmed else {
                    self?.showAlert(title: "エラー", message: "再入力されたパスワードが一致しません。")
                    return
                }
                
                // サインアップ処理
                self.performSignUp(email: email, password: password, name: name)
            }
        } else {
            // ログイン処理
            performLogin(email: email, password: password)
        }
    }

    // MARK: - バリデーション用関数
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
        showLoading() // ローディング開始
        authService.authenticate(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading() // ローディング終了
                switch result {
                case .success(let token):
                    // ログイン成功時にプロファイル取得を開始
                    self?.fetchUserProfile(token: token, isSignUp: false)
                case .failure(let error):
                    // 認証失敗時のエラーアラートを表示
                    self?.showAlert(title: "エラー", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - サインアップ処理
    private func performSignUp(email: String, password: String, name: String) {
        showLoading()
        authService.authenticate(email: email, password: password, signUpName: name) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                switch result {
                case .success(let token):
                    // サインアップ成功時にプロファイル取得を開始
                    self?.fetchUserProfile(token: token, isSignUp: true)
                case .failure(let error):
                    self?.showAlert(title: "エラー", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - プロファイル取得
    private func fetchUserProfile(token: String, isSignUp: Bool) {
        showLoading() // ローディング再開（プロファイル取得開始）
        let userProfileService = UserProfileService()
        userProfileService.fetchUserProfile(withToken: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading() // ローディング終了
                switch result {
                case .success:
                    // プロファイル取得成功時に文言を動的に変更
                    let message = isSignUp ? "登録が完了しました！" : "ログインしました！"
                    let alert = UIAlertController(title: "成功", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                        // OKを押したらメイン画面に遷移
                        self?.navigateToMain()
                    }))
                    self?.present(alert, animated: true, completion: nil)
                case .failure(let error):
                    // プロファイル取得失敗時のエラーアラートを表示
                    self?.showAlert(title: "エラー", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - ナビゲーション
    private func navigateToMain() {
        let mainTabBarController = MainTabBarController()
        // Backボタンを削除する設定
        mainTabBarController.navigationItem.hidesBackButton = true
        // 次の画面をPush
        navigationController?.pushViewController(mainTabBarController, animated: true)
    }

    // MARK: - アラート表示
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
