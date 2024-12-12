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
    
    // MARK: - authenticate
    private func authenticate() {
        guard let email = authInputView.emailTextField.text?.replacingOccurrences(of: " ", with: ""),
              let password = authInputView.passwordTextField.text?.replacingOccurrences(of: " ", with: ""),
              !email.isEmpty, !password.isEmpty else {
            // メールアドレスまたはパスワードが未入力または空白のみの場合のアラートを表示
            let alert = UIAlertController(title: "入力エラー", message: "メールアドレスまたはパスワードを入力してください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        
        if authMode == .signUp {
            // サインアップ時の処理
            // メールアドレスの形式を確認
            let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
            let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
            if !emailPredicate.evaluate(with: email) {
                let alert = UIAlertController(title: "入力エラー", message: "正しい形式のメールアドレスを入力してください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            // パスワードが空白を抜いて6文字以上でないとエラー
            if password.replacingOccurrences(of: " ", with: "").count < 6 {
                let alert = UIAlertController(title: "入力エラー", message: "パスワードは6文字以上で設定してください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            // 名前が10文字以下であることを確認
            let userProfileService = UserProfileService()
            guard let cleanedName = authInputView.nameTextField.text,
                  !cleanedName.replacingOccurrences(of: " ", with: "").isEmpty,
                  authInputView.nameTextField.text.count <= 10 else {
                let alert = UIAlertController(
                    title: "入力エラー",
                    message: "名前は10文字以下で空白以外の文字を含めてください。",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }

            
            // パスワード再確認アラートを表示する処理
            let confirmPasswordAlert = UIAlertController(title: "パスワード再確認", message: "もう一度パスワードを入力してください。", preferredStyle: .alert)
            confirmPasswordAlert.addTextField { textField in
                textField.isSecureTextEntry = true
                textField.placeholder = "パスワード"
            }
            confirmPasswordAlert.addAction(UIAlertAction(title: "確認", style: .default, handler: { [weak self] _ in
                let confirmedPassword = confirmPasswordAlert.textFields?.first?.text
                if confirmedPassword != password {
                    // パスワードが一致しない場合のエラーアラートを表示
                    let mismatchAlert = UIAlertController(title: "エラー", message: "再入力されたパスワードが一致しません。", preferredStyle: .alert)
                    mismatchAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(mismatchAlert, animated: true, completion: nil)
                    return
                }
                
                // サインアップの処理を開始
                self?.showLoading() // ローディング開始
                self?.authService.authenticate(email: email, password: password, signUpName: self?.authInputView.nameTextField.text) { result in
                    DispatchQueue.main.async {
                        self?.hideLoading() // ローディング終了
                        switch result {
                        case .success(let token):
                            self?.showLoading() // ローディング再開（プロファイル取得）
                            // 認証成功時のユーザープロファイル取得処理と成功アラート表示
                            let userProfileService = UserProfileService()
                            userProfileService.fetchUserProfile(withToken: token) { result in
                                DispatchQueue.main.async {
                                    self?.hideLoading() // プロファイル取得終了
                                    switch result {
                                    case .success:
                                        let successAlert = UIAlertController(title: "成功", message: "登録が完了しました！", preferredStyle: .alert)
                                        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                                            // メイン画面への遷移処理
                                            let mainTabBarController = MainTabBarController()
                                            let navigationController = UINavigationController(rootViewController: mainTabBarController)
                                            navigationController.modalPresentationStyle = .fullScreen
                                            self?.present(navigationController, animated: true, completion: nil)
                                        }))
                                        self?.present(successAlert, animated: true, completion: nil)
                                    case .failure(let error):
                                        let errorAlert = UIAlertController(title: "エラー", message: error.localizedDescription, preferredStyle: .alert)
                                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        self?.present(errorAlert, animated: true, completion: nil)
                                    }
                                }
                            }
                        case .failure(let error):
                            // 認証失敗時のエラーアラートを表示
                            let errorAlert = UIAlertController(title: "エラー", message: error.localizedDescription, preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(errorAlert, animated: true, completion: nil)
                        }
                    }
                }
            }))
            confirmPasswordAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            present(confirmPasswordAlert, animated: true, completion: nil)
        } else {
            // ログインの処理を開始
            showLoading() // ローディング開始
            authService.authenticate(email: email, password: password) { [weak self] result in
                DispatchQueue.main.async {
                    self?.hideLoading() // ローディング終了
                    switch result {
                    case .success(_):
                        let successAlert = UIAlertController(title: "成功", message: "ログインしました！", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                            // メイン画面への遷移処理
                            let mainTabBarController = MainTabBarController()
                            let navigationController = UINavigationController(rootViewController: mainTabBarController)
                            navigationController.modalPresentationStyle = .fullScreen
                            self?.present(navigationController, animated: true, completion: nil)
                        }))
                        self?.present(successAlert, animated: true, completion: nil)
                    case .failure(let error):
                        // 認証失敗時のエラーアラートを表示
                        let errorAlert = UIAlertController(title: "エラー", message: error.localizedDescription, preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
