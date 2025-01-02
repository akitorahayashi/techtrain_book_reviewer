//
//  TBRAlertHelper.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/27.
//

import UIKit

@MainActor
class TBRAlertHelper {
    /// エラー時においてOKボタンのあるアラートを表示する汎用的なメソッド
    static func showErrorAlert(on viewController: UIViewController?, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController?.present(alert, animated: true)
    }
    /// OKボタンのあるアラートを表示する汎用的なメソッド
    static func showSingleOKOptionAlert(on viewController: UIViewController?, title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // カスタムアクションがない場合、デフォルトでOKボタンを追加
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        
        viewController?.present(alert, animated: true)
    }
}
