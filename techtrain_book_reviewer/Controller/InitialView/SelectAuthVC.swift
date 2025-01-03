//
//  FirstViewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class SelectAuthVC: UIViewController {
    private weak var coordinator: SelectAuthCoordinatorProtocol?
    
    init(coordinator: SelectAuthCoordinatorProtocol?) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        print("Coordinator is \(coordinator != nil ? "set" : "nil")")
        let selectAuthView = SelectAuthView(
            showSignUpPageAction: { [weak self] in
                print("SignUp button tapped")
                self?.coordinator?.navigateToSignUp()
            },
            showLogInPageAction: { [weak self] in
                print("LogIn button tapped")
                self?.coordinator?.navigateToLogIn()
            }
        )
        view = selectAuthView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
