//
//  LoadingOverlayService.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/21.
//

import UIKit

@MainActor
class LoadingOverlayService {
    static let shared = LoadingOverlayService()
    
    private var overlayView: UIView?
    
    private init() {}
    
    func show() {
        guard overlayView == nil else { return } // 複数のオーバーレイ表示を防ぐ
        
        // アクティブなウィンドウシーンを取得
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // オーバーレイビューを作成
        let overlayView = UIView(frame: window.bounds)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        // ローディングインジケーターを作成
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = overlayView.center
        activityIndicator.startAnimating()
        // ローディングインジケーターをオーバーレイに追加
        overlayView.addSubview(activityIndicator)
        
        // オーバーレイをウィンドウに追加
        window.addSubview(overlayView)
        
        // フェードインで表示
        overlayView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            overlayView.alpha = 1
        }
        
        // オーバーレイを保持して管理
        self.overlayView = overlayView
        
        // ユーザー操作を無効化
        window.isUserInteractionEnabled = false
    }
    
    func hide() {
        guard let overlayView = overlayView else { return }
        
        // フェードアウトアニメーション
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 0
        }) { _ in
            // アニメーション完了後にオーバーレイを削除
            overlayView.removeFromSuperview()
            self.overlayView = nil
        }
        // ユーザー操作を有効化
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.isUserInteractionEnabled = true
        }
    }
}
