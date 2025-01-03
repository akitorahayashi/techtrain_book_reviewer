//
//  AuthInputCoordinator.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/03.
//

import UIKit

@MainActor
class AuthInputCoordinator: CoordinatorProtocol {
    let navigationController: UINavigationController
    // child coordinator
    private var mainTabBarCoordinator: MainTabBarCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MainTabBarControllerに進む
    func start() async {
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: self.navigationController)
        self.mainTabBarCoordinator = mainTabBarCoordinator
        let mainTabBarController = MainTabBarController(coordinator: mainTabBarCoordinator)
        mainTabBarController.navigationItem.hidesBackButton = true
        navigationController.pushViewController(mainTabBarController, animated: true)
    }
}
