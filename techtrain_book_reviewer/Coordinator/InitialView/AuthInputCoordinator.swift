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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MainTabBarControllerに進む
    func start() async {
        let mainTabBarController = MainTabBarController()
        mainTabBarController.navigationItem.hidesBackButton = true
        navigationController.pushViewController(mainTabBarController, animated: true)
    }
}
