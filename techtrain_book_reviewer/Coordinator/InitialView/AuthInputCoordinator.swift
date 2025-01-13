//
//  AuthInputCoordinator.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/03.
//

import UIKit

@MainActor
protocol AuthInputCoordinatorProtocol {
    func navigateToMainTabBarView()
}

@MainActor
class AuthInputCoordinator: AuthInputCoordinatorProtocol {
    let navigationController: UINavigationController
    // child coordinator
    private var mainTabBarCoordinator: MainTabBarCoordinator
    private var bookListCoordinator: BookReviewListCoordinator
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.mainTabBarCoordinator = MainTabBarCoordinator(navigationController: self.navigationController)
        self.bookListCoordinator = BookReviewListCoordinator(navigationController: self.navigationController)
    }
    
    // MainTabBarControllerに進む
    func navigateToMainTabBarView() {
        let mainTabBarController = MainTabBarController(
            mainTabBarCoordinator: mainTabBarCoordinator,
            bookReviewListCoordinator: bookListCoordinator
        )
        navigationController.pushViewController(mainTabBarController, animated: true)
    }
}
