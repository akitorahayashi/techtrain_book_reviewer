//
//  FirstViewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Book Reviewer"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .accent
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // タイトルラベルの作成
        let titleLabel = createTitleLabel()
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
        ])
        
        // サインインボタン
        let signInCard = TBRCardButton(title: "Sign In", action: handleSignIn)
        
        // ログインボタン
        let loginCard = TBRCardButton(title: "Log In", action: handleLogIn)
        
        // ボタンの配置
        let buttonStack = UIStackView(arrangedSubviews: [signInCard, loginCard])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.alignment = .fill
        
        view.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func handleSignIn() {
        print("Sign In tapped")
        let signInVC = SignInViewController()
        navigationController?.pushViewController(signInVC, animated: true)
    }
    
    @objc private func handleLogIn() {
        print("Log In tapped")
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
