//
//  MainTabBarCoordinator.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2025/01/03.
//

import UIKit

@MainActor
protocol MainTabBarCoordinatorProtocol: AnyObject {
    func logoutToSelectAuthVC() async
}

@MainActor
class MainTabBarCoordinator: MainTabBarCoordinatorProtocol {
    private let navigationController: UINavigationController
    // child coordinator
    private let selectAuthCoordinator: SelectAuthCoordinator
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.selectAuthCoordinator = SelectAuthCoordinator(navigationController: navigationController)
    }
    
    func logoutToSelectAuthVC() async {
        await UserProfileService().updateAccountState(newState: nil)
        await SecureTokenService.shared.deleteAPIToken()
        
        // 既存のスタックに SelectAuthVC があるか確認
        if !navigationController.viewControllers.contains(where: { $0 is SelectAuthVC }) {
            // SelectAuthVC がない場合は新規作成して表示
            let selectAuthVC = SelectAuthVC(coordinator: selectAuthCoordinator)
            navigationController.setViewControllers([selectAuthVC], animated: true)
        } else {
            // SelectAuthVC が既にスタックに存在する場合は戻る
            navigationController.popToViewController(
                navigationController.viewControllers.first { $0 is SelectAuthVC }!,
                animated: true
            )
        }
    }
}
