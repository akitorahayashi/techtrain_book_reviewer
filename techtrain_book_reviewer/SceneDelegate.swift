//
//  SceneDelegate.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private var appCoordinator: AppCoordinator?
    
    // シーンがアプリと連携されるときに呼び出されるメソッド
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: シーンがアプリに接続されました")
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.appCoordinator = AppCoordinator(windowScene: windowScene)
        // トークン読み取りと画面遷移処理
        Task {
            await self.appCoordinator?.start()
        }
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

