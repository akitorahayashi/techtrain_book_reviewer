//
//  FirstViewController.swift
//  techtrain_book_reviewer
//
//  Created by 林 明虎 on 2024/12/07.
//

import UIKit

class SelectAuthVC: UIViewController {
    
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
        let jumpToSignInButton = TBRCardButton(title: "Sign In", action: jumpToSignInView)
        
        // ログインボタン
        let jumpToLogInButton = TBRCardButton(title: "Log In", action: jumpToLogInView)
        
        // ボタンの配置
        let buttonStack = UIStackView(arrangedSubviews: [jumpToSignInButton, jumpToLogInButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.alignment = .fill
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func jumpToSignInView() {
        print("Sign In tapped")
        // サインインモードでビューコントローラを初期化
        let authInputVC = TBRAuthInputVC(mode: .signUp)
        // ナビゲーションコントローラで画面遷移
        navigationController?.pushViewController(authInputVC, animated: true)
    }
    
    @objc private func jumpToLogInView() {
        print("Log In tapped")
        // AuthInputView をサインインモードで初期化
        let authInputVC = TBRAuthInputVC(mode: .login)
        // ナビゲーションコントローラで画面遷移
        navigationController?.pushViewController(authInputVC, animated: true)
    }
}
