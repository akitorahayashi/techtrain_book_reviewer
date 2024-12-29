//
//  TBRAuthInputValidation.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/21.
//
import Foundation

enum TBRAuthError: Error {
    case invalidEmail
    case invalidPassword
    case invalidName

    /// 各エラーに対応するエラーメッセージを返す
    var errorMessage: (title: String, message: String) {
        switch self {
        case .invalidEmail:
            return ("入力エラー", "正しい形式のメールアドレスを入力してください")
        case .invalidPassword:
            return ("入力エラー", "パスワードは6文字以上20文字以下で設定してください")
        case .invalidName:
            return ("入力エラー", "名前は10文字以下で空白以外の文字を含めてください")
        }
    }
}


class TBRAuthInputValidator {
    /// メールアドレスのバリデーション
    static func isValidEmail(_ email: String?) -> Bool {
        guard let email = email, !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /// パスワードのバリデーション（6文字以上20文字以下）
    static func isValidPassword(_ password: String?) -> Bool {
        guard let password = password, !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        return password.count >= 6 && password.count <= 20
    }

    /// 名前のバリデーション（10文字以下、空白不可）
    static func isValidName(_ name: String?) -> Bool {
        guard let name = name else { return false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && trimmedName.count <= 10
    }

    /// 入力項目のバリデーションをまとめて実行
    static func validateAuthInput(email: String?, password: String?, name: String?, mode: AuthInputViewController.EmailAuthMode) -> [String] {
        var errors: [String] = []
        
        // メールアドレスのバリデーション
        if !isValidEmail(email) {
            errors.append("正しい形式のメールアドレスを入力してください")
        }
        
        // パスワードのバリデーション
        if !isValidPassword(password) {
            errors.append("パスワードは6文字以上20文字以下で設定してください")
        }
        
        // 名前のバリデーション（サインアップ時のみ）
        if mode == .signUp, !isValidName(name) {
            errors.append("名前は10文字以下で空白以外の文字を含めてください")
        }
        
        return errors
    }
}
