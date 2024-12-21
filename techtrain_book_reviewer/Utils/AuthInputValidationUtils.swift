//
//  AuthInputValidationUtils.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/21.
//

import Foundation

class AuthInputValidationUtils {
    /// メールアドレスのバリデーション
    static func isValidEmail(_ email: String?) -> Bool {
        guard let email = email else { return false }
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /// パスワードのバリデーション（6文字以上20文字以下）
    static func isValidPassword(_ password: String?) -> Bool {
        guard let password = password else { return false }
        return password.count >= 6 && password.count <= 20
    }

    /// 名前のバリデーション（10文字以下、空白不可）
    static func isValidName(_ name: String?) -> Bool {
        guard let name = name else { return false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && trimmedName.count <= 10
    }

    /// テキストが空白または空かどうかを判定
    static func isBlank(_ text: String?) -> Bool {
        guard let text = text else { return true }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
