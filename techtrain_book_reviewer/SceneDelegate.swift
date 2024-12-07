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
        print("SceneDelegate: scene(_:willConnectTo:options:) - シーンがアプリに接続されました")
        
        // シーンがUIWindowSceneであることを確認
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        // 初期画面としてFirstViewControllerを設定
        let rootViewController = UINavigationController(rootViewController: SelectAuthVC())
        window.rootViewController = rootViewController
        // 作成したウィンドウをアプリ全体のウィンドウとして設定
        self.window = window
        // ウィンドウを表示
        window.makeKeyAndVisible()
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

