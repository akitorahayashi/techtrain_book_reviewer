//
//  MainTabBarController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/11.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let createReviewVC = UINavigationController(rootViewController: CreateReviewViewController())
        createReviewVC.tabBarItem = UITabBarItem(title: "Create Review", image: UIImage(systemName: "square.and.pencil"), tag: 1)
        
        viewControllers = [homeVC, createReviewVC]
        tabBar.tintColor = .systemPink
    }
}
