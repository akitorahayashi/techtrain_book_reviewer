//
//  TBRAlertHelper.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/27.
//

import UIKit

class TBRAlertHelper {
    /// アラートを表示する汎用グローバルメソッド
    static func showSingleOptionAlert(on viewController: UIViewController?, title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // カスタムアクションがない場合、デフォルトでOKボタンを追加
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        
        viewController?.present(alert, animated: true)
    }
}
