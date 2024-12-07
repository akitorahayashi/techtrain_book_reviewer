//
//  AppDelegate.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // アプリの起動時
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate: アプリが起動しました")
        return true
    }
    // シーンセッションの作成時
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("AppDelegate: 新しいシーンセッションが作成されました")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // シーンセッションの破棄時
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("AppDelegate: シーンセッションが破棄されました。破棄されたセッション数: \(sceneSessions.count)")
    }
}
