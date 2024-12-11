//
//  SecureTokenService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import Foundation
import Security

class SecureTokenService {
    static let shared = SecureTokenService()
    let tokenKey = "\(String(describing: Bundle.main.bundleIdentifier)).authToken"
    private init() {}
    
    private let service = Bundle.main.bundleIdentifier ?? "com.akitorahayashi.techtrain-book-reviewer"
    
    func save(data: Data) -> Bool {
        let _ = delete() // 既存データの削除
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("SecureTokenService: データを保存しました")
            return true
        } else {
            print("SecureTokenService: データ保存に失敗しました（ステータスコード: \(status)）")
            return false
        }
    }
    
    func load() -> Data? {
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
    
    func delete() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("SecureTokenService: データを削除しました")
            return true
        } else {
            print("SecureTokenService: データ削除に失敗しました（ステータスコード: \(status)）")
            return false
        }
    }
}