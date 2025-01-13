//
//  FirstViewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class SelectAuthVC: UIViewController {
    private weak var selectAuthCoordinator: SelectAuthCoordinatorProtocol?
    private var selectAuthView: SelectAuthView?
    
    init(coordinator: SelectAuthCoordinatorProtocol?) {
        self.selectAuthCoordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.selectAuthView = SelectAuthView()
        view = selectAuthView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonActions()
    }
    
    private func setupButtonActions() {
        self.selectAuthView?.showSignUpPageButton.addTarget(self, action: #selector(signupButtonAction), for: .touchUpInside)
        self.selectAuthView?.showLogInPageButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
    }
    
    @objc func signupButtonAction() {
        self.selectAuthCoordinator?.navigateToSignUp()
    }
    
    @objc func loginButtonAction() {
        self.selectAuthCoordinator?.navigateToLogIn()
    }
}
