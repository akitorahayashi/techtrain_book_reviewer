//
//  FirstViewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class SelectAuthVC: UIViewController {
    override func loadView() {
        let selectAuthView = SelectAuthView(
            signUpAction: { [weak self] in self?.jumpToSignUpView() },
            logInAction: { [weak self] in self?.jumpToLogInView() }
        )
        view = selectAuthView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func jumpToSignUpView() {
        print("Sign Up tapped")
        let authInputVC = AuthInputViewController(authMode: .signUp)
        navigationController?.pushViewController(authInputVC, animated: true)
    }
    
    private func jumpToLogInView() {
        print("Log In tapped")
        let authInputVC = AuthInputViewController(authMode: .login)
        navigationController?.pushViewController(authInputVC, animated: true)
    }
}
