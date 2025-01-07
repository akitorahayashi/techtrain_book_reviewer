//
//  FirstViewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class SelectAuthVC: UIViewController {
    private weak var coordinator: SelectAuthCoordinatorProtocol?
    private var selectAuthView: SelectAuthView?
    
    init(coordinator: SelectAuthCoordinatorProtocol?) {
        self.coordinator = coordinator
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
        selectAuthView?.showSignUpPageButton.addTarget(self, action: #selector(signupButtonAction), for: .touchUpInside)
        selectAuthView?.showLogInPageButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
    }
    
    @objc func signupButtonAction() {
        self.coordinator?.navigateToSignUp()
    }
    
    @objc func loginButtonAction() {
        self.coordinator?.navigateToLogIn()
    }
}
