//
//  AppCoordinator.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/03.
//

import UIKit

@MainActor
protocol AppCoordinatorProtocol: AnyObject {
    func start() async
}

@MainActor
class AppCoordinator: AppCoordinatorProtocol {
    var window: UIWindow?
    let navigationController = UINavigationController()
    // child coordinator
    private var selectAuthCoordinator: SelectAuthCoordinator?
    private var mainTabBarCoordinator: MainTabBarCoordinator?
    private var bookReviewListCoordinator: BookReviewListCoordinator?
    
    init(windowScene: UIWindowScene) {
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = navigationController
        self.window?.backgroundColor = UIColor.systemBackground
        self.window?.makeKeyAndVisible()
    }
    
    func start() async {
        guard let tokenData = await SecureTokenService.shared.loadAPIToken(),
              let token = String(data: tokenData, encoding: .utf8) else {
            print("AppCoordinator: トークンが見つかりません")
            await showAuthInputScreen()
            return
        }
        do {
            try await UserProfileService().fetchUserProfileAndSetSelfAccount(withToken: token)
            print("AppCoordinator: Profile取得成功")
            await showBookListScreen()
        } catch {
            print("AppCoordinator: Profile取得失敗")
            let _ = await SecureTokenService.shared.deleteAPIToken()
            await showAuthInputScreen()
        }
    }
    
    private func showAuthInputScreen() async {
        let selectAuthCoordinator = SelectAuthCoordinator(navigationController: self.navigationController)
        self.selectAuthCoordinator = selectAuthCoordinator
        let selectAuthVC = SelectAuthVC(coordinator: selectAuthCoordinator)
        navigationController.setViewControllers([selectAuthVC], animated: false)
    }
    
    private func showBookListScreen() async {
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: self.navigationController)
        let bookReviewListCoordinator = BookReviewListCoordinator(navigationController: self.navigationController)
        self.mainTabBarCoordinator = mainTabBarCoordinator
        self.bookReviewListCoordinator = bookReviewListCoordinator
        let mainTabBarController = MainTabBarController(
            mainTabBarCoordinator: mainTabBarCoordinator,
            bookReviewListCoordinator: bookReviewListCoordinator
        )
        navigationController.setViewControllers([mainTabBarController], animated: false)
    }
}
