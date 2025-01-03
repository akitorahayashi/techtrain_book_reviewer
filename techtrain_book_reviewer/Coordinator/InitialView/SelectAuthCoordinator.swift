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
    let navigationController: UINavigationController
    
    init(_ selectAuthVC: SelectAuthVC? = nil, navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func navigateToSignUp() {
        print("navigateToSignUp called")
        let authInputVC = AuthInputVC(authMode: .signUp)
        navigationController.pushViewController(authInputVC, animated: true)
    }
    
    func navigateToLogIn() {
        print("navigateToLogIn called")
        let authInputVC = AuthInputVC(authMode: .login)
        navigationController.pushViewController(authInputVC, animated: true)
    }
}
