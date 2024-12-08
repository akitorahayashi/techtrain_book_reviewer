//
//  UIViewController+Loading.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/08.
//

import UIKit

extension UIViewController {
    func showLoading() {
        // オーバーレイビューを作成
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        overlayView.tag = 999
        overlayView.alpha = 0 // 初期状態で透明
        
        // ローディングインジケーターを作成
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = overlayView.center
        activityIndicator.startAnimating()
        
        // サブビューに追加
        overlayView.addSubview(activityIndicator)
        view.addSubview(overlayView)
        
        // アニメーションでオーバーレイを表示
        UIView.animate(withDuration: 0.3) {
            overlayView.alpha = 1 // 徐々に不透明に
        }
        
        // ユーザー操作を無効化
        view.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        // オーバーレイを取得
        guard let overlayView = view.subviews.first(where: { $0.tag == 999 }) else { return }
        
        // アニメーションでオーバーレイを非表示
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 0 // 徐々に透明に
        }) { _ in
            // アニメーション完了後に削除
            overlayView.removeFromSuperview()
            // ユーザー操作を有効化
            self.view.isUserInteractionEnabled = true
        }
    }
}
