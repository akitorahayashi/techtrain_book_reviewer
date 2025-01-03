//
//  AppCoordinator.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/03.
//

import UIKit

@MainActor
class AppCoordinator: Coordinator {
    
    private let window: UIWindow?
    let navigationController: UINavigationController
    
    init(window: UIWindow?) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() async {
        guard let tokenData = await SecureTokenService.shared.loadAPIToken(), let token = String(data: tokenData, encoding: .utf8) else {
            print("AppCoordinator: トークンが見つかりません")
            await showAuthScreen()
            return
        }
        
        do {
            try await UserProfileService.fetchUserProfileAndSetSelfAccount(withToken: token)
            print("AppCoordinator: Profile取得成功")
            await showBookListScreen()
        } catch {
            print("AppCoordinator: Profile取得失敗")
            let _ = await SecureTokenService.shared.deleteAPIToken()
            await showAuthScreen()
        }
    }
    
    private func showAuthScreen() async {
        let authVC = SelectAuthVC()
        navigationController.setViewControllers([authVC], animated: false)
        window?.rootViewController = navigationController
    }
    
    private func showBookListScreen() async {
        let mainTabBarController = MainTabBarController()
        navigationController.setViewControllers([mainTabBarController], animated: true)
        window?.rootViewController = navigationController
    }
}
