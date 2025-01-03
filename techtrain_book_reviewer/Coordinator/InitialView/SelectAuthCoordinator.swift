//
//  SelectAuthCoordinator.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/03.
//

import UIKit

@MainActor
protocol SelectAuthCoordinatorProtocol: AnyObject {
    func navigateToSignUp()
    func navigateToLogIn()
}

@MainActor
class SelectAuthCoordinator: SelectAuthCoordinatorProtocol {
    private var authInputCoordinator: AuthInputCoordinator?
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func navigateToSignUp() {
        print("navigateToSignUp called")
        let authInputCoordinator = AuthInputCoordinator(navigationController: self.navigationController)
        self.authInputCoordinator = authInputCoordinator
        let authInputVC = AuthInputVC(authMode: .signUp, authInputCoordinator: authInputCoordinator)
        navigationController.pushViewController(authInputVC, animated: true)
    }
    
    func navigateToLogIn() {
        print("navigateToLogIn called")
        let authInputCoordinator = AuthInputCoordinator(navigationController: self.navigationController)
        self.authInputCoordinator = authInputCoordinator
        let authInputVC = AuthInputVC(authMode: .login, authInputCoordinator: authInputCoordinator)
        navigationController.pushViewController(authInputVC, animated: true)
    }
}
