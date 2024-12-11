//
//  SceneDelegate.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // シーンがアプリと連携されるときに呼び出されるメソッド
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: シーンがアプリに接続されました")
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Launch Screen と同じ背景色を設定
        window.backgroundColor = UIColor.systemBackground // 適宜変更
        window.makeKeyAndVisible()
        
        // トークン読み取りと画面遷移処理
        handleTokenAndProceed()
    }
    
    private func handleTokenAndProceed() {
        if let tokenData = SecureTokenService.shared.load(),
           let token = String(data: tokenData, encoding: .utf8) {
            print("SceneDelegate: トークンを読み取りました: \(token)")
            
            let userProfileService = UserProfileService()
            userProfileService.fetchUserProfile(withToken: token) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("SceneDelegate: Profile取得成功")
                        self?.showHomeScreen()
                    case .failure:
                        print("SceneDelegate: Profile取得失敗")
                        let _ = SecureTokenService.shared.delete()
                        self?.showAuthScreen()
                    }
                }
            }
        } else {
            print("SceneDelegate: トークンが見つかりません")
            showAuthScreen()
        }
    }
    
    private func showAuthScreen() {
        // サインアップ/ログイン画面を表示
        let navigationController = UINavigationController(rootViewController: SelectAuthVC())
        window?.rootViewController = navigationController
    }
    
    private func showHomeScreen() {
        // SelectAuthVC をルートとして設定
        let selectAuthVC = SelectAuthVC()
        let navigationController = UINavigationController(rootViewController: selectAuthVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // SelectAuthVC から HomeViewController に遷移
        let mainVC = MainTabBarController()
        navigationController.pushViewController(mainVC, animated: false)
    }
    
    // シーンが切断されたときに呼び出される（リソース解放などに使用可能）
    func sceneDidDisconnect(_ scene: UIScene) {
        print("SceneDelegate: sceneDidDisconnect - シーンが切断されました")
    }
    
    // シーンがアクティブになったときに呼び出される（アプリがフォアグラウンドに戻る際など）
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("SceneDelegate: sceneDidBecomeActive - シーンがアクティブになりました")
    }
    
    // シーンが非アクティブになるときに呼び出される（バックグラウンドに移行する直前など）
    func sceneWillResignActive(_ scene: UIScene) {
        print("SceneDelegate: sceneWillResignActive - シーンが非アクティブになります")
    }
    
    // シーンがフォアグラウンドに入る直前に呼び出される
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("SceneDelegate: sceneWillEnterForeground - シーンがフォアグラウンドに戻ります")
    }
    
    // シーンがバックグラウンドに入ったときに呼び出される
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("SceneDelegate: sceneDidEnterBackground - シーンがバックグラウンドに入りました")
    }
}

