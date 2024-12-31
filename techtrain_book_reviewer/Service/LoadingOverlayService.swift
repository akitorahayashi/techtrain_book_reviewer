import UIKit

actor LoadingOverlayService {
    static let shared = LoadingOverlayService()
    
    private var overlayView: UIView?
    
    /// オーバーレイの表示
    @MainActor
    func show() async {
        guard overlayView == nil else { return } // 複数のオーバーレイ表示を防ぐ
        
        // ウィンドウの取得
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // オーバーレイビューを作成
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.3)
        overlay.isUserInteractionEnabled = true
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = overlay.center
        activityIndicator.startAnimating()
        
        overlay.addSubview(activityIndicator)
        window.addSubview(overlay)
        
        // フェードインで表示
        overlay.alpha = 0
        UIView.animate(withDuration: 0.3) {
            overlay.alpha = 1
        }
        
        // overlayViewを保持
        overlayView = overlay
        
        // ユーザー操作を無効化
        window.isUserInteractionEnabled = false
        
    }
    
    /// オーバーレイの非表示
    @MainActor
    func hide() async {
        guard let overlay = await overlayView else { return }
        
        // フェードアウトアニメーション
        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 0
        }) { _ in
            overlay.removeFromSuperview()
            await overlayView = nil
        }
        
        // ユーザー操作を有効化
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.isUserInteractionEnabled = true
        }
    }
}
