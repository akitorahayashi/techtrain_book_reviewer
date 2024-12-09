//
//  TBREmailAuthService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/08.
//

import UIKit

class TBREmailAuthService {
    
    enum AuthMode {
        case login
        case signUp
    }
    
    enum EmailAuthError: Error, Equatable {
        case invalidEmail
        case weakPassword
        case userNotFound
        case emailNotVerified
        case emailAlreadyInUse
        case unknown(Error)
        
        var localizedDescription: String {
            switch self {
            case .invalidEmail:
                return "メールアドレスの形式が正しくありません。"
            case .weakPassword:
                return "パスワードは6文字以上で入力してください。"
            case .userNotFound:
                return "ユーザーが見つかりません。"
            case .emailNotVerified:
                return "メールアドレスが確認されていません。"
            case .emailAlreadyInUse:
                return "このメールアドレスは既に使用されています。"
            case .unknown(let error):
                return error.localizedDescription
            }
        }
        
        // Equatableの実装
        static func == (lhs: EmailAuthError, rhs: EmailAuthError) -> Bool {
            switch (lhs, rhs) {
            case (.invalidEmail, .invalidEmail),
                 (.weakPassword, .weakPassword),
                 (.userNotFound, .userNotFound),
                 (.emailNotVerified, .emailNotVerified),
                 (.emailAlreadyInUse, .emailAlreadyInUse):
                return true
            case (.unknown(let lhsError), .unknown(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    func authenticate(email: String, password: String, mode: AuthMode, completion: @escaping (Result<Void, EmailAuthError>) -> Void) {
        switch mode {
        case .login:
            login(email: email, password: password, completion: completion)
        case .signUp:
            signUp(email: email, password: password, completion: completion)
        }
    }
    
    private func login(email: String, password: String, completion: @escaping (Result<Void, EmailAuthError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                completion(.failure(self.mapAuthError(error)))
                return
            }
            
            // メールアドレスが確認されていない場合
            if let user = result?.user, !user.isEmailVerified {
                completion(.failure(.emailNotVerified))
                return
            }
            
            completion(.success(()))
        }
    }
    
    private func signUp(email: String, password: String, completion: @escaping (Result<Void, EmailAuthError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error as NSError? {
                completion(.failure(self.mapAuthError(error)))
                return
            }
            
            // サインアップ成功時に認証メールを送信
            self.resendVerificationEmail(completion: nil)
            completion(.success(()))
        }
    }
    
    func resendVerificationEmail(completion: ((Result<Void, EmailAuthError>) -> Void)?) {
        guard let user = Auth.auth().currentUser else {
            completion?(.failure(.userNotFound))
            return
        }
        
        user.sendEmailVerification { error in
            if let error = error {
                completion?(.failure(.unknown(error)))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    func showResendVerificationAlert(on viewController: UIViewController, email: String) {
        let alert = UIAlertController(
            title: "メールアドレス未確認",
            message: "メールアドレスが確認されていません。確認メールを再送しますか？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "再送", style: .default, handler: { [weak self] _ in
            self?.resendVerificationEmail { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.showSimpleAlert(on: viewController, title: "確認メール送信", message: "確認メールを再送しました。")
                    case .failure(let error):
                        self?.showSimpleAlert(on: viewController, title: "エラー", message: error.localizedDescription)
                    }
                }
            }
        }))
        
        viewController.present(alert, animated: true)
    }
    
    private func showSimpleAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
    
    private func mapAuthError(_ error: NSError) -> EmailAuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error)
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        default:
            return .unknown(error)
        }
    }
}
