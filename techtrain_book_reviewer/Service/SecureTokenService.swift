//
//  SecureTokenService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit
import Security

actor SecureTokenService {
    static let shared = SecureTokenService()
    let tokenKey = "techtrain_book_reviewer_authToken"
    private init() {}
    
    private let service = Bundle.main.bundleIdentifier ?? "com.akitorahayashi.techtrain-book-reviewer"
    
    @MainActor
    func getTokenAfterLoad(on viewController: UIViewController?) -> String? {
        guard let token = UserProfileService.yourAccount?.token else {
                TBRAlertHelper.showErrorAlert(on: viewController, message: "認証情報が見つかりません。再度ログインしてください。")
            return nil
        }
        return token
    }
    
    func saveAPIToken(data: Data) throws(TechTrainAPIError) -> Void {
        let _ = deleteAPIToken() // 既存データの削除
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("SecureTokenService: データを保存しました")
        } else {
            print("SecureTokenService: データ保存に失敗しました（ステータスコード: \(status)）")
            throw TechTrainAPIError.keychainSaveError
        }
    }
    
    func loadAPIToken() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            print("SecureTokenService: データを読み取りました")
            return result as? Data
        } else {
            print("SecureTokenService: データ読み取りに失敗しました（ステータスコード: \(status)）")
            return nil
        }
    }
    
    func deleteAPIToken() -> Void {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("SecureTokenService: データを削除しました")
        } else {
            print("SecureTokenService: データ削除に失敗しました（ステータスコード: \(status)）")
        }
    }
}
